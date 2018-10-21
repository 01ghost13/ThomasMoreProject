class CreateTests < ActiveRecord::Migration[4.2]
  def change
    create_table :tests do |t|
      t.string :name
      t.string :description
      t.string :version
      t.timestamps null: false
    end
  end
end
