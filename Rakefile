ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __FILE__)
require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

require 'rake'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new do |t|
end

task :default => :spec
