class CreatePictureInterests < ActiveRecord::Migration
  def change
    create_table :picture_interests do |t|
      t.integer :earned_points #weight of link between interest and picture
      
      t.belongs_to :picture, foreign_key: true, index: true
      t.belongs_to :interest, foreign_key: true, index: true
      
      t.timestamps null: false
    end
  end
end
