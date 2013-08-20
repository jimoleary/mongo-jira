require 'mongo_jira/config'
require 'mongo_jira/patch'
module MongoJira

  #noinspection ALL
  class Jira

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
      @config ||= MongoJira::Config.new(filename)
    end
    
    def method_missing(m, *args, &block)  
      jira.send(m, *args, &block)
    end
    
  end
end