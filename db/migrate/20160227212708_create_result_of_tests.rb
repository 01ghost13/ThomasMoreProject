class CreateResultOfTests < ActiveRecord::Migration[4.2]
  def change
    create_table :result_of_tests do |t|
      t.boolean :was_in_school #Boolean flag from student
      t.boolean :is_ended #Has test ended?
      t.belongs_to :test
      t.belongs_to :schooling
      t.belongs_to :student
      
      t.timestamps null: false
    end
  end
end
