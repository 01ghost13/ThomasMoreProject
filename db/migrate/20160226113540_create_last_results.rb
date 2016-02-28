class CreateLastResults < ActiveRecord::Migration
  def change
    create_table :last_results do |t|
      t.integer :time
      t.date :date
      t.boolean :is_finished
      t.integer :current_question
      
      t.timestamps null: false
    end
    
    create_table :last_results_points, index: false do |t|
      t.belongs_to :last_results, index: true
      t.belongs_to :point, index: true
    end
  end
end
