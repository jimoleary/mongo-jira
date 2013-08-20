module Mongo
  module Jira
    module Model
      class Comment
        attr_accessor :attrs
        def initialize(comment)
          @comment= comment
        end

        def tengen?
          email =~ /@10gen.com$/
        end

        def updated
          @updated||=DateTime.parse(@comment.updated).strftime('%D %T')
        end

        def display_name
          @display_name ||=@comment.author['displayName']
        end

        def name
          @name ||=@comment.author['name']
        end

        def email
          @email ||=@comment.author['emailAddress']
        end

        def visibility
          @visibility ||= begin
            v = (@comment.attrs['visibility']||{})['value']
            v = 'Everybody' if v.blank?
            v
          end
        end

        def body
          @body ||= @comment.body
        end

      end
    end
  end
end