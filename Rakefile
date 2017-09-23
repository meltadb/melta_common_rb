require 'rspec/core/rake_task'
require "rake/testtask"

RSpec::Core::RakeTask.new

task :default => :spec

Rake::TestTask.new do |t|
  t.verbose = true
  t.libs.push("demo", "test")
  t.pattern = "test/**/*_test.rb"
end