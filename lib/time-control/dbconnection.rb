require 'active_record'
require 'yaml'
require 'logger'

dbconfig = YAML::load(File.open('db/config.yml'))
env = ENV["RAILS_ENV"] || 'development'

ActiveRecord::Base.establish_connection(dbconfig[env])