class CreatePoints < ActiveRecord::Migration[4.2]
  def change
    create_table :points do |t|
      t.integer :earned_points
      t.belongs_to :interest, index: true, foreign_key: true
      t.belongs_to :result_of_test, index: true, foreign_key: true
      
      t.timestamps null: false
    end
  end
end
