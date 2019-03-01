class AddBoundsOfPictureToGazeResults < ActiveRecord::Migration[5.2]
  def change
    add_column :gaze_trace_results, :picture_bounds, :json, default: {}
  end
end
