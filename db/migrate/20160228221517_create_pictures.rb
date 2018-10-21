class CreatePictures < ActiveRecord::Migration[4.2]
  def change
    create_table :pictures do |t|
      t.string :path
      t.string :description
      
      t.timestamps null: false
    end
  end
end
