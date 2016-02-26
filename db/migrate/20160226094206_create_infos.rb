class CreateInfos < ActiveRecord::Migration
  def change
    create_table :infos do |t|
      t.string :name
      t.string :last_name
      t.string :mail
      t.string :password
      t.string :phone
      t.boolean :confirmation
      
      t.timestamps null: false
    end
  end
end
