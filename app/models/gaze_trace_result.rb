class GazeTraceResult < ActiveRecord::Base

  def scale_heatmap(scale_ratio: 1)
    gaze_points.map do |gp|
      gp[1] = {
        value: 1,
        x: (gp[1]['x'].to_i * scale_ratio).floor,
        y: (gp[1]['y'].to_i * scale_ratio).floor
      }
    end
  end
end
