Gem::Specification.new do |s|
  s.name               = 'mongo-jira'
  s.version            = '0.0.0'
  s.default_executable = 'mongo-jira'
  s.executables << 'jira'

  s.required_rubygems_version = Gem::Requirement.new('>= 0') if s.respond_to? :required_rubygems_version=
  s.authors = ['Jim O\'Leary']
  s.date = %q{2013-08-17}
  s.description = %q{Easy/Simple Jira command line tool}
  s.email = %q{jim.oleary@10gen.com}
  s.files = %w{Rakefile lib/mongo_jira.rb lib/mongo_jira/config.rb lib/mongo_jira/config_exception.rb lib/mongo_jira/patch.rb bin/jira}
  s.test_files = %w{test/test_jira_mongo.rb}
  s.homepage = %q{http://rubygems.org/gems/mongo_jira}
  s.license       = 'MIT'
  s.require_paths = %w(lib)
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{Jira Mongo command line tools}
  s.add_dependency 'jira-ruby',    ['>= 0.1.2']
  s.add_dependency 'commander',    ['>= 4.1.5']
  s.add_dependency 'ruby-progressbar',    ['>= 1.2.0']
  if s.respond_to? :specification_version
    s.specification_version = 3
    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0')
    else
    end
  else
  end
end
