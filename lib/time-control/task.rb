module TimeControl
  class Task
  	attr_accessor :name, :start_time, :end_time

  	def initialize(task_settings=nil)
  		return if task_settings.nil?

		if task_settings.is_a?(Hash)
			@name = task_settings[:name] || task_settings['name']
			@start_time = task_settings[:start] || task_settings['start']
		end

		@name = task_settings if task_settings.is_a?(String) || task_settings.is_a?(Symbol)
		@name = @name.to_s
  	end

  	def self.parse(task_description)
  	end
  end
end