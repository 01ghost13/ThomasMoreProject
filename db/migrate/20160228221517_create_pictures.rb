class CreatePictures < ActiveRecord::Migration
  def change
    create_table :pictures do |t|
      t.string :path
      t.string :description
      
      t.timestamps null: false
    end
    create_table :pictures_questions, id: false do |t|
      t.belongs_to :pictures, index: true
      t.belongs_to :questions, index: true
    end
  end
end
