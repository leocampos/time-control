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
        
        return if ['exit', 'quit', 'abort'].any? {|text| line == text}
        
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

  		Task.prepare_creation(:name => name, :start => start_time, :ending => end_time)
  	end
  	
  	private
  	def fit_new_task()
  	  return if self.respond_to? :skip_callback
      # if self.end_time.nil?
      #   former_tasks = Task.where("start_time >= ? OR (start_time < ? AND (end_time > ? or end_time IS NULL))", [start_time, start_time, start_time])
      #       else
      #         former_tasks = Task.where("end_time > ? and start_time < ?", [start_time, end_time])
      #       end
      
      last_task = Task.last
      return unless last_task #This is the first task entered on the system

      #Most common case: Last task has no ending and starts before actual task
      if last_task.end_time.nil? && last_task.start_time < self.start_time
        last_task.update_attributes(:end_time => self.start_time)
        return
      end
      
      #Case 2: Last task had finished before this task start
      if (not last_task.end_time.nil?) && last_task.end_time < self.start_time
        #Nothing to do
        return
      end
      
      #Case 3: Actual task starts between last_task start and end, but finishes after
      if last_task.start_time < self.start_time && last_task.end_time > self.start_time && (self.end_time.nil? || last_task.end_time < self.end_time)
        last_task.update_attributes(:end_time => self.start_time)
        return
      end
      
      #Case 4: Actual task is contained within start and end_time of last_task
      if (not (self.end_time.nil? || last_task.end_time.nil?)) && last_task.start_time < self.start_time && last_task.end_time > self.end_time
        #In this cenario, last task has to be broken into two pieces
        new_last_task = Task.new(:name => last_task.name, :start_time => self.end_time, :end_time => last_task.end_time)
        class << new_last_task
          def skip_callback;end
        end
        new_last_task.save
        
        last_task.update_attributes(:end_time => self.start_time)
      end
      
      #Case 5: Actual task starts somewhere before last task, but has no ending
      if self.end_time.nil? && self.start_time < last_task.start_time
        #we'll have to delete all tasks which starts after the actual one
        Task.delete_all(["start_time > ?", self.start_time])
        #Now we reccur to recursion to save the day
        fit_new_task
        return 
      end
      
      #Case 6: Actual task is contained in a former task time
      if (not self.end_time.nil?) && self.start_time < last_task.start_time
        container_task = Task.where('start_time < :start_date AND end_time > :end_date', {:start_date => self.start_time, :end_date => self.end_time})
        unless container_task.nil? || container_task.size == 0
          container_task = container_task.first
          new_last_task = Task.new(:name => container_task.name, :start_time => self.end_time, :end_time => container_task.end_time)
          class << new_last_task
            def skip_callback;end
          end
          new_last_task.save

          container_task.update_attributes(:end_time => self.start_time)
          
          return
        end
      end
      
      #Case 7: Actual task starts somewhere inside a task and ends somewhere inside another task
      if (not self.end_time.nil?) && self.start_time < last_task.start_time
        #This should return 2 tasks that should serve as guides to find the remaining ones
        former_tasks = Task.where('(start_time < :start_time AND end_time > :start_time) OR (start_time < :end_time AND end_time > :end_time)', {:start_time => self.start_time, :end_time => self.end_time}).order("start_time ASC")
        
        unless former_tasks.nil? || former_tasks.size != 2 
          first_former = former_tasks.first
          last_former = former_tasks.last

          Task.delete_all(["start_time >= ? AND end_time <= ?", first_former.end_time, last_former.start_time])
          first_former.update_attributes(:end_time => self.start_time)
          last_former.update_attributes(:end_time => self.start_time)
          return
        end
      end
      
      #Case 8: Actual task starts somewhere inside a task and ends after all tasks
      unless self.end_time.nil?
        if self.start_time < last_task.start_time #it must have started before last task
          if (last_task.end_time.nil? && self.end_time > last_task.start_time) # actual task should be ending after last task
            #It should delete all tasks that start after this start and call for recursion
            Task.delete_all(["start_time >= ?", self.start_time])
            fit_new_task
            return
          end  
        end
      end
    end
  end
end