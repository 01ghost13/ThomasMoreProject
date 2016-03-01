class CreatePointLastResults < ActiveRecord::Migration
  def change
    create_table :point_last_results do |t|
      t.integer :earned_points
      t.belongs_to :interest, index: true, foreign_key: true
      t.belongs_to :last_result, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
