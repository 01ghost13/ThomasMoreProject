class AddDefaultToGazePoints < ActiveRecord::Migration[5.2]
  def change
    change_column :gaze_trace_results, :gaze_points, :json, default: []
  end
end
