# == Schema Information
#
# Table name: gaze_trace_results
#
#  id             :bigint           not null, primary key
#  gaze_points    :json
#  screen_width   :integer
#  screen_height  :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  picture_bounds :json
#

class GazeTraceResult < ActiveRecord::Base
  # gaze_points: [1: {x:1, y:2}]


  def scale_heatmap(scale_ratio: 1)
    gaze_points.map do |gp|
      gp[1] = {
        value: 1,
        x: (gp[1]['x'].to_i * scale_ratio).floor,
        y: (gp[1]['y'].to_i * scale_ratio).floor
      }
    end
  end

  def normalize(height: 768, width: 1366)
    scale_width = screen_width / width
    scale_height = screen_height / height
    gaze_points.map do |gp|
      {
        x: (gp[1]['x'].to_f * scale_width).floor,
        y: (gp[1]['y'].to_f * scale_height).floor
      }
    end
  end

  def inside_picture_points
    down_left = picture_bounds.values.first
    top_right = picture_bounds.values.second
    return [] if down_left.blank? || top_right.blank?
    gaze_points.values.select { |gp| inside_picture?(gp) }
  end

  def inside_picture?(point)
    down_left = picture_bounds.values.first
    top_right = picture_bounds.values.second
    return false if down_left.blank? || top_right.blank?

    range_x = [top_right['x'].to_f, down_left['x'].to_f].sort
    range_y = [top_right['y'].to_f, down_left['y'].to_f].sort
    point['x'].to_f.between?(*range_x) && point['y'].to_f.between?(*range_y)
  end

  def inside_buttons_points
    gaze_points.values.select { |gp| inside_buttons?(gp) }
  end

  def inside_buttons?(point)
    top_left = { x: 98, y: 82 }.transform_keys(&:to_s)
    down_right = { x: 293, y: 277 }.transform_keys(&:to_s)
    range_x = [top_left['x'].to_f, down_right['x'].to_f].sort
    range_y = [top_left['y'].to_f, down_right['y'].to_f].sort
    inside_left = point['x'].to_f.between?(*range_x) && point['y'].to_f.between?(*range_y)

    top_left = { x: 1073, y: 82 }.transform_keys(&:to_s)
    down_right = { x: 1268, y: 277 }.transform_keys(&:to_s)
    range_x = [top_left['x'].to_f, down_right['x'].to_f].sort
    range_y = [top_left['y'].to_f, down_right['y'].to_f].sort
    inside_right = point['x'].to_f.between?(*range_x) && point['y'].to_f.between?(*range_y)

    inside_left || inside_right
  end
end
