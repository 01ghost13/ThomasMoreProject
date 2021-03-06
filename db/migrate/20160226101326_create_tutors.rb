class CreateTutors < ActiveRecord::Migration[4.2]
  def change
    create_table :tutors do |t|
      t.belongs_to :info, index: true, unique: true, foreign_key: true
      t.belongs_to :administrator, index: true, foreign_key: true
      
      t.timestamps null: false
    end
  end
end
