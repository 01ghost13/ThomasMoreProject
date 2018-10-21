class CreateQuestions < ActiveRecord::Migration[4.2]
  def change
    create_table :questions do |t|
      t.integer :number
      t.boolean :is_tutorial
      t.belongs_to :picture, index: true, foreign_key: true
      t.belongs_to :test, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
