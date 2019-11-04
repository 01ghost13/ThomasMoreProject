class RenameTutorToMentor < ActiveRecord::Migration[5.2]
  def change
    rename_table :tutors, :mentors
    rename_column :clients, :tutor_id, :mentor_id
  end
end
