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
      t.belongs_to :tutor, index: true, unique: true, foreign_key: true
      t.belongs_to :stat_id, index: true, unique: true, foreign_key: true
      t.belongs_to :mode, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
