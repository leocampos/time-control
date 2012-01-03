require 'rubygems'
require "bundler/setup"

module TimeControl
  autoload :Task,   File.dirname( __FILE__ ) + '/time-control/task'
  
  module Parser
    autoload :TaskTimeParser, File.dirname( __FILE__ ) + '/time-control/task_time_parser'
  end
end