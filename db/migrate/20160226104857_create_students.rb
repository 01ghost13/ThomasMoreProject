class CreateStudents < ActiveRecord::Migration
  def change
    create_table :students do |t|
      t.string :name
      t.string :last_name
      t.date :birth_date
      t.string :phone
      t.date :date_off
      t.boolean :gender
      t.string :adress
      t.boolean :is_active
      
      t.timestamps null: false
    end
  end
end
