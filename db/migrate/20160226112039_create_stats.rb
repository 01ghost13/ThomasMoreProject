class CreateStats < ActiveRecord::Migration
  def change
    create_table :stats do |t|
      t.integer :count_successed_tests
      #in seconds
      t.integer :max_time
      t.integer :min_time
      t.integer :avg_time
      
      t.timestamps null: false
    end
    
    create_table :stats_points, id: false do |t|
      t.belongs_to :stat, index: true
      t.belongs_to :point, index: true
    end
  end
end
