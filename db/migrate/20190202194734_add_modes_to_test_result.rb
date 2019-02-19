class AddModesToTestResult < ActiveRecord::Migration[5.2]
  def change
    add_column :result_of_tests, :emotion_recognition, :boolean, default: false
    add_column :result_of_tests, :gaze_trace, :boolean, default: false
  end
end
