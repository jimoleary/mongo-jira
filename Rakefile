require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:spec) do |t|
  t.libs << ['spec', File.expand_path('../', __FILE__)]
  t.pattern = 'spec/**/*_spec.rb'
end