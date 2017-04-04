class RemovePathFromPicture < ActiveRecord::Migration[5.0]
  def change
    remove_column :pictures, :path, :string
  end
end
