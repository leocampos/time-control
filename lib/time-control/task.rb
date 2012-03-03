module TimeControl
  class Task < ActiveRecord::Base
    before_create :fit_new_task
    validates_presence_of :name 
    
  	def self.prepare_creation(task_settings=nil)
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
        
        if ['exit', 'quit', 'abort'].any? {|text| line == text}
          last_task = Task.last
          return unless last_task
          
          last_task.update_attributes(:end_time => Time.now) if last_task.end_time.nil?
          return
        end
        
        task = parse(line)
        task_name = task.name
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
  		  time_setting = time_setting.striped_value
  		  
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

  		Task.prepare_creation(:name => name, :start => start_time, :ending => end_time)
  	end
  	
  	private
  	def fit_new_task()
  	  return if self.respond_to? :skip_callback
      
      #we should find the start affected task and the end affected task
      first_affected_task = Task.where(["start_time < ? AND (end_time IS NULL OR end_time > ?)", self.start_time, self.start_time])
      last_affected_task = self.end_time.nil? ? [] : Task.where(["start_time < ? AND (end_time IS NULL OR end_time > ?)", self.end_time, self.end_time])
      
      first_affected_task = first_affected_task.size == 0 ? nil : first_affected_task[0]
      last_affected_task = last_affected_task.size == 0 ? nil : last_affected_task[0]
      
      #Starts before all tasks and end after all tasks
      if first_affected_task.nil? && last_affected_task.nil?
        Task.delete_all(['start_time > ?', self.start_time]) #the query is a sauf-guard from the possibility of all task being closed
        return
      end
      
      #starts somewhere between a task, but ends after all other tasks
      if first_affected_task && last_affected_task.nil? 
        Task.delete_all(["start_time >= ?", self.start_time])
        first_affected_task.update_attributes(:end_time => self.start_time)
        
        return
      end
      
      #starts before all tasks, but ends between some task
      if first_affected_task.nil? && last_affected_task
        Task.delete_all(["start_time >= ? AND end_time <= ?", self.start_time, last_affected_task.start_time])
        last_affected_task.update_attributes(:start_time => self.end_time)
        
        return
      end
      
      #this means the actual task is contained within a task
      if first_affected_task == last_affected_task
        if last_affected_task.end_time.nil?
          first_affected_task.update_attributes(:end_time => self.start_time)
          return
        end
        
        new_last_task = Task.new(:name => last_affected_task.name, :start_time => self.end_time, :end_time => last_affected_task.end_time)
        class << new_last_task
          def skip_callback;end
        end
        new_last_task.save
        
        first_affected_task.update_attributes(:end_time => self.start_time)
        
        return
      end
      
      #From this point on we know this task starts within a former task and ends within another task
      Task.delete_all(["start_time >= ? AND end_time <= ?", first_affected_task.end_time, last_affected_task.start_time])
      first_affected_task.update_attributes(:end_time => self.start_time)
      last_affected_task.update_attributes(:end_time => self.start_time)
    end
  end
end