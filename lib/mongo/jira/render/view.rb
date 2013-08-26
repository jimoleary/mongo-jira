require 'erubis'

module Mongo
  module Jira
    module Render
      class View
        def initialize
        end

        def options=(opts={})
          @opts =opts ||{}
          @opts.symbolize_keys!
          @loc = @opts[:loc]
          #@view= (@opts[:view] || 'terminal').to_s
          @templates=@loc #|| File.join(Gem::Specification.find_by_name('mongo-jira').gem_dir, 'lib', 'view')
          @context=@opts
        end

        def render(obj, type=nil)
          [obj].flatten.collect do |o|
            clazz= o.class.to_s.split(/::/).last.downcase
            type ||= clazz

            #f = File.join(@templates, @view, type.to_s)
            f = File.join(@templates, type.to_s)
            f = "#{f}.erb" unless f.ends_with?('.erb')

            debug "view f #{f}"
            eruby = Erubis::Eruby.new(File.read(f))
            eruby.instance_variable_set(:@render, self)
            unless eruby.respond_to?(:render)
              def eruby.render(*args)
                @render.render(*args)
              end
              eruby.class.send(:include, RenderMethods)
            end

            c = (@context ||{}).inject({}) { |h, kv| k, v = kv; h["@#{k}"] =v; h }
            trace '--- code ---'
            trace eruby.src
            trace '--- result ---'
            eruby.result(c.merge({type => o, clazz => o, "@#{type}" => o, clazz => o})).gsub(/\\%/, '%')

          end.join("\n")
        end

        module RenderMethods
          def cs(value)
            s = value.gsub(/[\s+'-]+/,'').downcase.to_s
            HighLine.color_scheme.keys.include?(s) ? s : 'unknown'
          end
          def colorize(value,v=false)
            return value if value.nil?

            if v
              c = case value
                    when /^\d+\.(0|2|4|6|8)/;
                      'released'
                    when /^\d+\.(1|3|5|7|9)/;
                      'rc'
                    else
                      ; 'error'
                  end
            else
              c = value
            end
            "<%= color(\"#{value}\", '#{cs(c)}') %>"
          end

        end
      end
    end
  end
end
