module Mongo

  #noinspection ALL
  module Jira
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


    end
  end
end