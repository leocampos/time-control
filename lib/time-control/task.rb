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
  		@parser = TimeControl::Parser::TaskTimeParser.new

  		nodes = @parser.parse(task_description)

  		name = nodes.name
  		time_setting = nodes.time_setting
      start_time = nil
  		
  		unless time_setting.nil?
        mtc = nil
  			if (mtc = time_setting.match(/^([+-])(\d+)([smhd])$/))
  				now = Time.now
  				operator = mtc[1]
  				amount = mtc[2]
  				unit = mtc[3]

  				start_time = now
  			elsif time_setting =~ /^\d{2}$/
  			elsif time_setting =~ /^\d{4}$/
  			elsif time_setting =~ /^\d{2}-\d{2}$/
  			elsif time_setting =~ /^\d{2}-\d{4}$/
  			end
  		end

  		Task.new(:name => name, :start => start_time)
  	end
  end
end