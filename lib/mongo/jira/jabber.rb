require 'xmpp4r'
require 'commander/import'

# require "mongo/jira/jabber"
# jabber = Mongo::Jira::Jabber.new({})
# jabber.password
# jabber.talk "jim.oleary@10gen.com", "test","ing"

module Mongo
  module Jira
    class Jabber
      attr_accessor :config
      def initialize(cfg={})
        cfg ||={}
        @config = {
          :jid=>(cfg[:jid] || 'jim.oleary@10gen.com'),
          :host=>(cfg[:host] || 'talk.google.com'),
          :port=>(cfg[:port] || '5222'),
          :password=>cfg[:password]
        }
      end
      def cl
        @cl ||= begin
          cl = ::Jabber::Client.new(::Jabber::JID.new(from))
          cl.connect(host, port)
          cl.auth(password)
          cl
        end
      end
      def host
        @host ||= @config[:host]
      end
      def port
        @port ||= (@config['port'] ? @config['port'].to_i : 5222)
      end
      def from
        @from ||= @config[:jid]
      end
      def password
        @password ||= (@config[:password] || ask('password  ? ') { |q| q.echo = '*' })
      end
      def talk(to, subject,body)
        [to].flatten.each do |r|
          cl.send(::Jabber::Message.new(r, body).set_type(:normal).set_id('1').set_subject(subject))
        end
      end

    end
  end
end
