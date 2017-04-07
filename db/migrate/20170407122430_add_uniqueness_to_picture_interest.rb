class AddUniquenessToPictureInterest < ActiveRecord::Migration[5.0]
  def change
    add_index :picture_interests, [:interest_id, :picture_id], unique: true
  end
end
