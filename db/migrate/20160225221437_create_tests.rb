class CreateTests < ActiveRecord::Migration
  def change
    create_table :tests do |t|
      t.string :name
      t.string :description
      t.string :version
      t.timestamps null: false
    end
  end
end
