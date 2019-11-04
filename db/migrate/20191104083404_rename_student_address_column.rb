class RenameStudentAddressColumn < ActiveRecord::Migration[5.2]
  def change
    rename_column :students, :adress, :address
  end
end
