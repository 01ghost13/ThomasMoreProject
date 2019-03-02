class ChangeDefaultValueForGazePoints < ActiveRecord::Migration[5.2]
  def change
    change_column_default :gaze_trace_results, :gaze_points, {}
  end
end
