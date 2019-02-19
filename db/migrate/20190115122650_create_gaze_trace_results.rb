class CreateGazeTraceResults < ActiveRecord::Migration[5.2]
  def change
    create_table :gaze_trace_results do |t|
      t.json    :gaze_points
      t.integer :screen_width
      t.integer :screen_height

      t.timestamps
    end
  end
end
