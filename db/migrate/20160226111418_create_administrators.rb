class CreateAdministrators < ActiveRecord::Migration
  def change
    create_table :administrators do |t|
      t.boolean :is_super
      t.string :organisation
      
      t.timestamps null: false
    end
  end
end
