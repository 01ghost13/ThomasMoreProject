class CreateTranslatedColumns < ActiveRecord::Migration[5.2]
  def change
    create_table :translated_columns do |t|
      t.string :target_column, null: false
      t.string :translation, null: false
      t.references :translatable, polymorphic: true, index: { name: 'translatable_index' }
      t.belongs_to :language, null: false

      t.timestamps
    end
  end
end
