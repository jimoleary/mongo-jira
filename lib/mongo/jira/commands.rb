module Mongo

  #noinspection ALL
  module Jira
    class DummyProgressBar
      def initialize(s)
        @size = s
      end

      def method_missing(meth, *args)
        print '.' if meth.to_s == 'progress=' && args[0] == @size
      end
    end

    class Commands

      def init(filename)
        if Mongo::Jira::Config.check(filename)
          return false unless agree("#{filename} exists, <%= color('Overwrite?', RED) %> ")
        end

        conf = {}
        conf[:username] = prompt('username', 'jim.oleary@10gen.com')
        conf[:password] = ask("password (<%= color('hit ENTER for none', :password) %>) ? ") { |q| q.echo = '*' }
        conf[:site] = prompt('site', 'https://jira.mongodb.org')
        conf[:auth_type] = prompt('auth_type', 'basic')
        conf.delete(:password) if conf[:password].blank?

        Mongo::Jira::Config::save(conf, filename)
        true
      end

      def download(tid, options)
        ticket = client.find(tid)
        force = options[:force]

        unless ticket
          puts "no ticket for #{tid}"
          return
        end
        trace JSON.pretty_generate(ticket.attrs) if ticket

        trace "options #{options[:to]}"
        #noinspection RubyResolve
        ticket.attachments.each do |attachment|
          trace JSON.pretty_generate(attachment.attrs)
          u = URI.parse(attachment.content)
          parts = u.path.split('/') #[2..-1].join('/')
          to = options[:to].nil? ? tid : options[:to]
          trace "to -> #{to}"
          if options[:flatten]
            target = [to, parts.last]
          else
            target = [to, parts[3..-1]]
          end
          target = File.join(target.flatten)

          trace target
          size = attachment.attrs['size']
          debug "checking #{target} => #{File.exists?(target)}"
          if !force.any? { |g| File.fnmatch(g, target) } && File.exists?(target) && File.size(target) == size
            say("<%= color('skipping', :downloaded) %> already downloaded '#{target}'")
            next
          end

          name = target.split(%r{/}).last
          title = name[0..14].ljust(15)
          format = '%T %a |%b>%i|'
          length= 80

          pb = ProgressBar.create(:format => format,
                                  :title => title,
                                  :total => size,
                                  :throttle_rate => 0.1,
                                  :length => length)
          pb = DummyProgressBar.new(size) if options[:silent]

          progress=0
          if options[:dryrun]
            pb.format('%T |%b>%i|')
            pb.title = name[0..29].ljust(30)
            pb.progress=size
          else
            client.get(u.path) do |response|
              FileUtils.mkdir_p(File::dirname(target))
              debug u, ' => ', target
              File.open target, 'w' do |io|
                response.read_body do |chunk|
                  progress+=chunk.length
                  if progress == size
                    pb.format('%T |%b>%i|')
                    pb.title = name[0..29].ljust(30)
                  end
                  pb.progress=progress
                  io.write chunk
                end
              end
            end
          end
        end

      end

      def projects(globs, options)
        all = client.projects
        projects = all.find_all { |p|globs.any? { |g|File.fnmatch(g, p.key)}}
        projects= limit(projects, options[:limit])

        say render(projects, {:reverse => options[:reverse], :as =>(options[:as] ||:project)}) if projects.length > 0
        projects
      end

      def show(ids, options)
        tickets = ids.collect { |tid| client.find(tid)}
        tickets = limit(tickets, options[:limit])

        tickets.each do |ticket|
          say render(Mongo::Jira::Model::Ticket.new(ticket), {:reverse => options[:reverse], :as => options[:as]})
        end
        tickets
      end

      def open(ids, options)
        tickets = ids.collect { |tid| client.find(tid) }

        tickets = limit(tickets, options[:limit])

        tickets.each do |ticket|
          trace JSON.pretty_generate(ticket.attrs)
          %x{open 'https://jira.mongodb.org/browse/#{ticket.key}'}
        end
        tickets
      end

      def query(args, options)
        q = args.join(' ')
        debug ":find '#{q}'"
        all = client.jql(q)
        tickets = limit(all, options[:limit])

        tickets.each { |ticket| say render(Mongo::Jira::Model::Ticket.new(ticket), {:reverse => options[:reverse], :as => options[:as] || :header}) }
        tickets
      end

      def find(args, options)
        pattern = args.join(' ')
        q = %w{ summary description comment}.collect { |field| "#{field} ~ '#{pattern}'" }.join(' OR ')
        debug ":find '#{q}'"
        all = client.jql(q)

        tickets = limit(all, options[:limit])

        tickets.each do |ticket|
          trace JSON.pretty_generate(ticket.attrs)
          say render(Mongo::Jira::Model::Ticket.new(ticket), {:reverse => options[:reverse], :as => options[:as] || :header})
        end
        tickets
      end

      def fixversions(args, options)
        fv = args
        debug ":fv '#{fv}'"

        jql = "project in (#{options[:from].join(',')}) and fixVersion in (#{fv.collect { |v| "\"#{v}\"" }.join(',')})"
        log(jql)
        tickets = client.jql(jql)

        jql = tickets.collect { |ticket|
          "issue in linkedIssues(#{ticket.key},\"depends on\")"
          "issue in linkedIssues(#{ticket.key})"
        }.join(' or ')
        jql = "project in (#{options[:to].join(',')}) AND #{jql}"
        log(jql)
        tickets = client.jql(jql)

        tickets.each do |ticket|
          trace JSON.pretty_generate(ticket.attrs)
          say render(Mongo::Jira::Model::Ticket.new(ticket), {:reverse => options[:reverse], :as=> ($as||'terminal/header')})
        end
        tickets
      end


      def limit(tickets, limit=nil)
        debug "limit #{tickets} -> #{limit}"
        tickets.compact! if tickets
        return tickets if tickets.nil? || tickets.empty? || limit.nil?

        debug "limit #{tickets.length} -> #{limit}"
        tickets = [tickets].flatten.compact
        limit = limit.to_i - 1
        debug "limit #{tickets.length} -> #{limit}"
        if limit <=0
          t = [tickets.first]
        else
          t = tickets[0..limit]
        end
        debug "limit #{t.length} -> #{limit}"
        t
      end

      def client(config=$config)
        @jira ||= begin
          jira = Mongo::Jira::Main.new(config)
          jira.password = ask('Password:  ') { |q| q.echo = '*' } unless jira.password?
          jira
        rescue Mongo::Jira::ConfigException
          say("\n  <%= color('UNEXPECTED ERROR', :error) %>\n\n    conf file not found :: <%= color(\"#{config}\", RED) %>\n")
          command(:help).run('init')
          abort ''
        end
      end

      def render(ticket, o={})
        debug "starting render(ticket=#{ticket}, o=#{o})"
        @renderer ||= Mongo::Jira::Render::View.new()
        o||= {:as => 'terminal/ticket'}
        o[:as] = 'terminal/ticket' if o[:as].nil? or o[:as].blank?
        as = o[:as].to_s
        if as.length == 1
          o[:loc] = [as, 'terminal']
        else
          path = File.split(as)
          if as.start_with?('.', File::SEPARATOR)
            @type = path.pop
            o[:loc] = path
          else
            path.delete_at(0) if path.first == '.'
            if path.length == 1
              @type =path.pop
              o[:loc] = [Gem::Specification.find_by_name('mongo-jira').gem_dir, 'lib', 'view'] + %w(terminal)
            else
              o[:loc] = [Gem::Specification.find_by_name('mongo-jira').gem_dir, 'lib', 'view'] + path
              @type =o[:loc].pop if path.length > 1
            end
          end
        end
        @type||='ticket'
        @renderer.options= o
        debug "calling render(ticket=#{ticket}, o=#{o})"

        @renderer.render(ticket, @type.to_s)
      end


    end
  end
end