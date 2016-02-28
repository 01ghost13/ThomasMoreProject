class CreateModes < ActiveRecord::Migration
  def change
    create_table :modes do |t|

      t.timestamps null: false
    end
  end
end
