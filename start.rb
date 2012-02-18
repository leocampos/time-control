lib_path = File.expand_path('../lib', __FILE__)
$:.unshift lib_path unless $:.include? lib_path

require 'rubygems'
require 'ruby-debug' 
require 'time-control/dbconnection'
require 'time-control'
require 'readline'
require 'highline/import'
require 'active_support/core_ext'
require "treetop"

puts "Welcome to Time Control"

TimeControl::Task.ask_for_task