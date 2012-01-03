class CreateTaskMigration < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.string :name
      t.timestamp :start_time
      t.timestamp :end_time
      t.timestamps
    end
  end

  def self.down
    drop_table :tasks
  end
end
