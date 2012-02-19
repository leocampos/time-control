require 'spec_helper'

describe TimeControl::Task do
  context 'the class' do
    it 'should respond to parse' do
      TimeControl::Task.should respond_to(:parse)
    end

    context 'when the constructor is called' do
      it 'without any parameters it should create an empty task' do
        task = TimeControl::Task.new
        task.name.should be_nil
        task.start_time.should be_nil
        task.end_time.should be_nil
      end

      it 'should create task with its name attribute setted if first param is a String/Symbol' do
        task_name = "This is a task name"
        task = TimeControl::Task.prepare_creation(task_name)
        task.name.should == task_name

        task = TimeControl::Task.prepare_creation(:email)
        task.name.should == 'email'
      end

      context 'with a hash argument' do
        it 'it should create a task with its name attribute setted if hash has a :name/"name" key' do
          task_name = "This is a task name"
          task = TimeControl::Task.prepare_creation(:name => task_name)
          task.name.should == task_name

          task = TimeControl::Task.prepare_creation('name' => task_name)
          task.name.should == task_name
        end

        it 'should create a task with start_time if hash has a :start/"start" key' do
          time = Time.mktime(2011,12,15)

          task = TimeControl::Task.prepare_creation(:start => time)
          task.start_time.should == time

          task = TimeControl::Task.prepare_creation('start' => time)
          task.start_time.should == time
        end
      end
    end

    context 'when parse is called' do
      before(:each) do
        Time.stubs(:now).returns(Time.mktime(2011,12,15,9,5))
      end

      it 'should return an instance in accordance to the syntax' do
        task = TimeControl::Task.parse("task name")
        task.should_not be_nil
        task.name.should == 'task name'
        task.start_time.should == Time.mktime(2011,12,15,9,5)

        task = TimeControl::Task.parse("task name +5m")
        task.name.should == 'task name'
        time = Time.mktime(2011,12,15,9,10)
        task.start_time.should == time

        task = TimeControl::Task.parse("task name 1600-1700")
        task.name.should == 'task name'
        start_time = Time.mktime(2011,12,15,16)
        end_time = Time.mktime(2011,12,15,17)
        task.start_time.should == start_time
        task.end_time.should == end_time
        
        task = TimeControl::Task.parse("task name 16-17")
        task.name.should == 'task name'
        start_time = Time.mktime(2011,12,15,16)
        end_time = Time.mktime(2011,12,15,17)
        task.start_time.should == start_time
        task.end_time.should == end_time
      end
    end
  end

  context 'the instance' do
    before(:each) do
      @task = TimeControl::Task.new
    end

    it 'should respond to name' do
      @task.should respond_to(:name)
    end

    it 'should respond to start_time' do
      @task.should respond_to(:start_time)
    end

    it 'should respond to end_time' do
      @task.should respond_to(:end_time)
    end
    
    context 'when saved' do
      it "should be invalid without a taskname" do
        task = TimeControl::Task.new
        task.should_not be_valid
        task.name = 'name'
        task.should be_valid
      end
      
      context 'given time settings' do
        before :each do
          TimeControl::Task.delete_all
          
          TimeControl::Task.create([
            {:name => 'First Task', :start_time => Time.mktime(2011,12,15,9,5), :end_time => Time.mktime(2011,12,15,9,15)},
            {:name => 'Second Task', :start_time => Time.mktime(2011,12,15,9,15)}
          ])
        end
        
        context 'with start_time gt start_time of last task and last task s end time null' do
          it 'should use start time as last tasks end time' do
            task = TimeControl::Task.create(:name => 'Third Task', :start_time => Time.mktime(2011,12,15,9,25))
            
            TimeControl::Task.find_by_name('Second Task').end_time.should == task.start_time
          end
        end
        
        context 'with start_time gt end_time of last task' do
          it 'should use start time as last tasks end time' do
            third_task = TimeControl::Task.create(:name => 'Third Task', :start_time => Time.mktime(2011,12,15,9,25), :end_time => Time.mktime(2011,12,15,9,35))
            fourth_task = TimeControl::Task.create(:name => 'Fourth Task', :start_time => Time.mktime(2011,12,15,9,55))
            
            TimeControl::Task.find_by_name('Third Task').end_time.should == Time.mktime(2011,12,15,9,35)
          end
        end
        
        context 'with start_time between last tasks beginning and ending and actual ending null' do
          it 'should update last tasks ending to be the actual starting time' do
            third_task = TimeControl::Task.create(:name => 'Third Task', :start_time => Time.mktime(2011,12,15,9,00), :end_time => Time.mktime(2011,12,15,9,40))
            fourth_task = TimeControl::Task.create(:name => 'Fourth Task', :start_time => Time.mktime(2011,12,15,9,20))
            
            TimeControl::Task.find_by_name('Third Task').end_time.should == Time.mktime(2011,12,15,9,20)
          end
        end
        
        context 'with start_time between last tasks beginning and ending and actual ending greater than last tasks ending' do
          it 'should update last tasks ending to be the actual starting time' do
            third_task = TimeControl::Task.create(:name => 'Third Task', :start_time => Time.mktime(2011,12,15,9,00), :end_time => Time.mktime(2011,12,15,9,40))
            fourth_task = TimeControl::Task.create(:name => 'Fourth Task', :start_time => Time.mktime(2011,12,15,9,20), :end_time => Time.mktime(2011,12,15,9,50))
            
            TimeControl::Task.find_by_name('Third Task').end_time.should == Time.mktime(2011,12,15,9,20)
          end
        end
        
        context 'with start_time and end_time between last tasks start_time and end_time' do
          it 'should save actual task splitting last task in two' do
            third_task = TimeControl::Task.create(:name => 'Third Task', :start_time => Time.mktime(2011,12,15,9,00), :end_time => Time.mktime(2011,12,15,11,00))
            fourth_task = TimeControl::Task.create(:name => 'Fourth Task', :start_time => Time.mktime(2011,12,15,9,20), :end_time => Time.mktime(2011,12,15,9,50))
            
            TimeControl::Task.where(:name => 'Third Task').size.should == 2
          end
        end
        
        context 'with start time before several tasks start time and end time after all of those' do
          it 'should delete all tasks in between' do
            TimeControl::Task.create(:name => 'Third Task', :start_time => Time.mktime(2011,12,15,9,0), :end_time => Time.mktime(2011,12,15,9,25))
            
            TimeControl::Task.all.size.should == 1
          end
        end
        
        context 'contained within an old task' do
          it 'should split this task apart' do
            TimeControl::Task.create(:name => 'Third Task', :start_time => Time.mktime(2011,12,15,9,6), :end_time => Time.mktime(2011,12,15,9,14))
            
            TimeControl::Task.where(:name => 'First Task').size.should == 2
          end
        end
        
        context 'starts within a task and ends within another taks' do
          it 'should split this task apart' do
            TimeControl::Task.create([
              {:name => 'Third Task', :start_time => Time.mktime(2011,12,15,9,25), :end_time => Time.mktime(2011,12,15,9,35)},
              {:name => 'Fourth Task', :start_time => Time.mktime(2011,12,15,9,35), :end_time => Time.mktime(2011,12,15,9,45)},
              {:name => 'Fifth Task', :start_time => Time.mktime(2011,12,15,9,45)}
            ])
            
            TimeControl::Task.create(:name => 'Sixth Task', :start_time => Time.mktime(2011,12,15,9,6), :end_time => Time.mktime(2011,12,15,9,44))
            
            TimeControl::Task.all.size.should == 4
          end
        end
        
        # Possible situations:
        #   Case 1: There is an open task and actual task has start time after last task's beginning time
        #     A:  ------ 
        #         ------
        #     B:  ------ 
        #         xxxxxx
        #     => new task
        # 
        #   Case 2: Last task is closed and actual task's starting time is after last task's ending time
        #     A:  ------ 
        #         ------
        #     B:  ------ 
        #         ------
        #     => new task
        #     
        #   Case 3: New task starts between last task's starting and ending time
        #     A:  ------ 
        #         ------
        #     B:  ------ 
        #         ------
        #     => new task
      end
    end
  end
end