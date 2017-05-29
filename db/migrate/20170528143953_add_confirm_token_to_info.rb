class AddConfirmTokenToInfo < ActiveRecord::Migration[5.0]
  def change
    add_column :infos, :confirm_token, :string, null: true
  end
end
