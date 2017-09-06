class AddResetToken < ActiveRecord::Migration[5.0]
  def change
    add_column :infos, :reset_token, :string, null: true
  end
end
