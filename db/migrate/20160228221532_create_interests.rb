class CreateInterests < ActiveRecord::Migration
  def change
    create_table :interests do |t|
      t.string :name
      t.timestamps null: false
    end
    
    create_table :interests_pictures, id: false do |t|
      t.belongs_to :interests, index: true
      t.belongs_to :pictures, index: true
    end
  end
end
