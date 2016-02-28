class CreatePoints < ActiveRecord::Migration
  def change
    create_table :points do |t|
      t.integer :earned_points
      
      t.timestamps null: false
    end
  end
end
