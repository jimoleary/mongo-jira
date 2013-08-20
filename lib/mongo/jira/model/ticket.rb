module Mongo
  module Jira
    module Model
      class Ticket
        attr_accessor :attrs
        def initialize(ticket)
          @ticket= ticket
          @attrs={key:ticket.key ,
                  description:ticket.description,
                  status:ticket.status.name,
                  summary:ticket.summary ,
                  fix_versions:(ticket.try(:fixVersions) ? ticket.fixVersions.collect{|v|v["name"]} : []),
                  priority:ticket.priority.name,
                  company: (ticket.send(COMPANY_FIELD)||{})['name'],
                  status:ticket.status.attrs['name'],
                  resolution:(ticket.resolution ? ticket.resolution['name'] : 'Unresolved'),
                  comments:ticket.comments.collect{|c|Mongo::Jira::Model::Comment.new(c)}
          }
        end

        def method_missing(meth, *args)
          return @attrs[meth] if  @attrs.key?(meth)
          return @ticket.attrs['fields'][meth] if  @ticket.attrs['fields'].key?(meth)
          super
        end

        COMPANY_FIELD = 'customfield_10030'
      end
    end
  end
end
