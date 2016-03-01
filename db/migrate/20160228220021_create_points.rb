class CreatePoints < ActiveRecord::Migration
  def change
    create_table :points do |t|
      t.integer :earned_points
      t.belongs_to :interest, index: true, foreign_key: true
      t.belongs_to :stats, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
