module TimeControl
  class Task < ActiveRecord::Base
    validates_presence_of :name
    
  	def self.instantiate(task_settings=nil)
  		return if task_settings.nil?
  		
  		name = nil
  		start_time = nil
  		end_time = nil
  		if (task_settings.is_a?(String) || task_settings.is_a?(Symbol))
  		  name = task_settings.to_s
		  else
		    name = task_settings[:name] || task_settings['name']
		    start_time = task_settings[:start] || task_settings['start']
  		  end_time = task_settings[:ending] || task_settings['ending']
	    end
  		
  		Task.new(:name => name, :start_time => start_time, :end_time => end_time)
  	end
  	
  	def self.ask_for_task
      list = most_used_list
      comp = proc { |s| list.grep( /^#{Regexp.escape(s)}/ ) }

      Readline.completion_append_character = " "
      Readline.completion_proc = comp

      loop do
        say 'Task:'

        line = Readline.readline('', true)
        
        return if ['exit', 'quit', 'abort'].any? {|text| line == text}
        
        task = parse(line)
        task_name = task.name
        debugger
        task.save

        list << task_name unless list.include? task_name
      end
    end
  	
  	def self.most_used_list
  	  select("name, count(id) as count").group("name").order('count desc, name').limit(100)
	  end

  	def self.parse(task_description)
  		@parser = TimeControl::Parser::TaskTimeParser.new

  		nodes = @parser.parse(task_description)

  		name = nodes.name.text_value
  		time_setting = nodes.time_setting
      start_time = Time.now
      end_time = nil
  		
  		unless time_setting.nil? || time_setting.text_value.empty?
  		  time_setting = time_setting.text_value
  		  
        mtc = nil
        now = Time.now
        
  			if (mtc = time_setting.match(/^([+-])(\d+)([smhd])$/))
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
  			  minute = mtc[2] || '00'
  			  hour = mtc[1]
  			  
  			  start_time = Time.mktime(now.year, now.month, now.day, hour.to_i, minute.to_i, 0)
        elsif (mtc = time_setting.match(/^(\d{4}|\d{2})-(\d{4}|\d{2})$/))
          start = mtc[1]
          ending = mtc[2]
          
          start_hour = start[0,2]
          start_minute = start.size == 4 ? start[2,4] : 0
          
          end_hour = ending[0,2]
          end_minute = ending.size == 4 ? ending[2,4] : 0
          
          start_time = Time.mktime(now.year, now.month, now.day, start_hour.to_i, start_minute.to_i, 0)
          end_time = Time.mktime(now.year, now.month, now.day, end_hour.to_i, end_minute.to_i, 0)
  			end
  		end

  		Task.instantiate(:name => name, :start => start_time, :ending => end_time)
  	end
  end
end