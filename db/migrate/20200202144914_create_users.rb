class CreateUsers < ActiveRecord::Migration[5.2]
  def up
    create_table :users do |t|
      t.integer :role, null: false
      t.references :userable, polymorphic: true, null: false
      t.boolean :is_active, null: false, default: true
      t.date :date_off

      t.timestamps
    end
  end

  def down
    drop_table :users, if_exists: true
  end
end
