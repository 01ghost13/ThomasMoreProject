class AddSettingsForStudents < ActiveRecord::Migration[5.2]
  def change
    add_column :students, :emotion_recognition, :boolean, default: false
    add_column :students, :gaze_trace, :boolean, default: false
  end
end
