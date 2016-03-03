class CreateSchoolings < ActiveRecord::Migration
  def change
    create_table :schoolings do |t|
      t.string :name
      
      t.timestamps null: false
    end
  end
end
