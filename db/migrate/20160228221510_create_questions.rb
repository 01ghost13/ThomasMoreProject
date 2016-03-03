class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.integer :number
      t.boolean :is_tutorial
      t.belongs_to :picture, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
