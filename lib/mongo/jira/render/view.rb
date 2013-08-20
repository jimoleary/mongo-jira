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
          @view= (@opts[:view] || 'terminal').to_s
          @templates=@loc|| File.join(Gem::Specification.find_by_name('mongo-jira').gem_dir, 'lib', 'view')
          @context=@opts
        end

        def render(obj, type=nil)
          [obj].flatten.collect do |o|
            clazz= o.class.to_s.split(/::/).last.downcase
            type ||= clazz

            f = File.join(@templates, @view, type.to_s)
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
          def render_status(value)
            return value if value.nil?
            "<%= color(\"#{value}\", :#{value.gsub(/\s+/,'').downcase}) %>"
          end

          def render_resolution(value)
            return value if value.nil?
            "<%= color(\"#{value}\", :#{value.downcase}) %>"
          end

          def render_priority(value)
            return value if value.nil?
            c = case value
                  when /p1$/i ; ':p1'
                  when /p2$/i ; ':p2'
                  when /p3$/i ; ':p3'
                  when /p4$/i ; ':p4'
                  when /p5$/i ; ':p5'
                  else ':error'
                end
            "<%= color(\"#{value}\", #{c}) %>"
          end

          def render_versions(value)
            return value if value.nil?
            c = case value
                  when /^\d+\.(0|2|4|6|8)/;
                    ':released'
                  when /^\d+\.(1|3|5|7|9)/;
                    ':rc'
                  else
                    ; ':error'
                end
            "<%= color(\"#{value}\", #{c}) %>"
          end

          def render_dev_only(value, plain=false)
            return value if value.nil? or !plain
            case value
              when /developer/i;
                "<%= color('Dev Only', :dev_only) %>"
              when /customer/i;
                "<%= color('Customer Only', :dev_only) %>"
              else
                ; nil
            end
          end
        end
      end
    end
  end
end
