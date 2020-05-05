class AddLanguageToUser < ActiveRecord::Migration[5.2]
  def change
    add_belongs_to :users, :language, null: false, default: 1
    # lang_id = Language.all.first.id

    # User.all.each { |u| u.update_column(:language_id, lang_id) }
  end
end
