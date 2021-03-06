class AddTableTranslations < ActiveRecord::Migration[5.2]
  def change
    create_table :translations do |t|
      t.string :field, null: false
      t.string :value, null: false
      t.belongs_to :language, null: false
    end

    add_index :translations, %i[field language_id], unique: true
  end
end
