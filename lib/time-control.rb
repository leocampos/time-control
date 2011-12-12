require 'rubygems'
require "bundler/setup"

module TimeControl
  autoload :Task, 'time-control/task'
  
  module Parser
    autoload :TaskTimeParser, 'time-control/task_time_parser'
  end
end