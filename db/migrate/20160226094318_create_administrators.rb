class CreateAdministrators < ActiveRecord::Migration[4.2]
  def change
    create_table :administrators do |t|
      t.boolean :is_super
      t.string :organisation
      t.belongs_to :info, index: true, unique: true, foreign_key: true
      
      t.timestamps null: false
    end
  end
end
