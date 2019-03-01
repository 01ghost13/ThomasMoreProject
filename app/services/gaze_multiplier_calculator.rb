class GazeMultiplierCalculator
  attr_reader :question_results
  attr_reader :multipliers

  def initialize(question_results)
    @question_results = question_results
    @multipliers = count_multipliers(gaze_results_by_interests)
  end

  def gaze_results_by_interests
    result = {}
    @question_results.each do |q_result|
      next if q_result.was_checked != 3
      question = q_result.question
      gaze_points = [q_result.gaze_trace_result]
      result.merge!(question.picture.interests.map { |i| [i.name, gaze_points] }.to_h) do |_, old_gaze_points, new_gaze_points|
        old_gaze_points + new_gaze_points
      end
    end
    result
  end

  def recount_results(interest_points)
    interest_points.merge(@multipliers) do |_, interest_point, multiplier|
      counter_function(interest_point, multiplier)
    end
  end

  private

    def count_multipliers(results_by_interests)
      results_by_interests.transform_values do |gaze_result_array|
        total_count = gaze_result_array.flat_map { |gaze_result| gaze_result.gaze_points.values }.count
        inside_picture_count = gaze_result_array.flat_map(&:inside_picture_points).count
        inside_picture_count.to_f / total_count.to_f
      end
    end

    def counter_function(old_point, multiplier)
      new_multiplier =
          if old_point.between?(0, 0.3)
            2.0 * multiplier
          elsif old_point.between?(0.3, 0.6)
            0.5 * multiplier + 0.2
          else
            5.0 / 7.0 * multiplier + 0.5
          end
      old_point * new_multiplier
    end
end
