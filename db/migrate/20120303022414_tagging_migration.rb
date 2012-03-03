class TaggingMigration < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.string :name
      t.timestamps
    end
    
    create_table :tags_tasks, :id => false do |t|
      t.integer :tag_id
      t.integer :task_id
    end
  end

  def self.down
    drop_table :tags
    drop_table :tags_tasks
  end
end
