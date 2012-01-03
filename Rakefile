begin
  require 'tasks/standalone_migrations'
rescue LoadError => e
  puts "gem install standalone_migrations to get db:migrate:* tasks! (Error: #{e})"
end

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __FILE__)
require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

require 'rake'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new do |t|
end

# To load rake tasks on lib/task folder
# load 'lib/tasks/task_sample.rake'
task :default => :spec
