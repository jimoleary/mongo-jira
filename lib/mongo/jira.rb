require "mongo/jira/version"

require 'mongo/jira/config'
require 'mongo/jira/patch'
module Mongo

  #noinspection ALL
  module Jira
    class Main

      attr_accessor :filename, :jira, :config

      def initialize(file)
        @filename= file
      end
      
      def find(tid)
        jira.Issue.find(tid)
      rescue JIRA::HTTPError => e
        raise e if e.code == '401' || e.code == '403'
        nil
      end
      
      def jql(qry)
        JIRA::Resource::Issue.jql(jira,qry)
      end
      
      def projects
        jira.Project.all
      end
      
      def jira
        @jira ||= JIRA::Client.new(config.config)
      end
      
      def password?
        config.password?
      end
      def password=(pw)
        config.password=pw
      end
      
      def config
        @config ||= Mongo::Jira::Config.new(filename)
      end
      
      def method_missing(m, *args, &block)  
        jira.send(m, *args, &block)
      end
      
    end
  end
end
