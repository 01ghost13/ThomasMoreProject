class RenameStudentForeignKeys < ActiveRecord::Migration[5.2]
  def change
    rename_column :result_of_tests, :student_id, :client_id
  end
end
