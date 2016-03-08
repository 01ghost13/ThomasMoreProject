class CreateStudents < ActiveRecord::Migration
  def change
    create_table :students do |t|
      t.string :code_name, unique: true
      t.date :birth_date
      t.date :date_off #date of student deactivating
      t.integer :gender
      t.string :adress
      t.boolean :is_active
      t.string :password_digest
      t.boolean :is_current_in_school
      t.belongs_to :schooling, index: true, foreign_key: true
      t.belongs_to :tutor, index: true, foreign_key: true
      t.belongs_to :mode, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
