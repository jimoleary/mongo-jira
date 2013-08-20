# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mongo/jira/version'

Gem::Specification.new do |s|
  s.name               = 'mongo-jira'
  s.version            = Mongo::Jira::VERSION #'0.0.0'
  s.platform    = Gem::Platform::RUBY
  s.authors = ['Jim O\'Leary']
  s.email = %q{jim.oleary@gmail.com}
  s.homepage = %q{http://rubygems.org/gems/mongo-jira}
  s.summary = %q{Simple Mongo Jira command line tools}
  s.description = %q{Easy/Simple Jira command line tool}
  s.rubyforge_project = 'mongo_jira'
  s.signing_key = "#{ENV['HOME']}/.ssh/gem-private_key.pem"
  s.cert_chain  = ["#{ENV['HOME']}/.ssh/gem-public_cert.pem"]

 
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]


  s.add_dependency 'jira-ruby'#,    ['>= 0.1.2']
  s.add_dependency 'commander'#,    ['>= 4.1.5']
  s.add_dependency 'ruby-progressbar'#,    ['>= 1.2.0']
  s.add_dependency 'xmpp4r'#,    ['>= 1.2.0']
  s.add_dependency 'erubis'#,    ['>= 1.2.0']
end
