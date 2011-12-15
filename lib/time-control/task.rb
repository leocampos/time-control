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

          hour = 3600
          day = 24 * hour
          
          unit_mapping = {'s'=>1, 'm' => 60, 'h' => hour, 'd' => day}
          seconds = (amount.to_i * unit_mapping[unit])
          seconds *= -1 if operator == '-'
          
  				start_time = now + seconds
  			elsif (mtc = time_setting.match(/^(\d{2})(\d{2})?$/))
  			  minute = mtc[2]
  			  hour = mtc[1]
  			elsif (mtc = time_setting.match(/^(\d{4}|\d{2})-(\d{4}|\d{2})$/)
  			end
  		end

  		Task.new(:name => name, :start => start_time)
  	end
  end
end