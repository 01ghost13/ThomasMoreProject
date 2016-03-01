class CreateLastResults < ActiveRecord::Migration
  def change
    create_table :last_results do |t|
      t.integer :time
      t.date :date
      t.boolean :is_finished
      t.integer :current_question
      
      t.timestamps null: false
    end
  end
end
