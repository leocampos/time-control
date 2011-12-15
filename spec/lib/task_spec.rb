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
        task = TimeControl::Task.new(task_name)
        task.name.should == task_name

        task = TimeControl::Task.new(:email)
        task.name.should == 'email'
      end

      context 'with a hash argument' do
        it 'it should create a task with its name attribute setted if hash has a :name/"name" key' do
          task_name = "This is a task name"
          task = TimeControl::Task.new(:name => task_name)
          task.name.should == task_name

          task = TimeControl::Task.new('name' => task_name)
          task.name.should == task_name
        end

        it 'should create a task with start_time if hash has a :start/"start" key' do
          time = Time.mktime(2011,12,15)

          task = TimeControl::Task.new(:start => time)
          task.start_time.should == time

          task = TimeControl::Task.new('start' => time)
          task.start_time.should == time
        end
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
  end
end