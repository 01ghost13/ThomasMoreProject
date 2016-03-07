class CreateInfos < ActiveRecord::Migration
  def change
    create_table :infos do |t|
      t.string :name
      t.string :last_name
      t.string :mail
      t.string :password_digest
      t.string :phone
      t.boolean :is_mail_confirmed
      
      t.timestamps null: false
    end
  end
end
