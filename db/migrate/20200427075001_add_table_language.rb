class AddTableLanguage < ActiveRecord::Migration[5.2]
  def change
    create_table :languages do |t|
      t.string :name, null: false
    end
  end
end
