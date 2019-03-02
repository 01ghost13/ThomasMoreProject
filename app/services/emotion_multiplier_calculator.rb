class EmotionMultiplierCalculator
  attr_reader :question_results
  attr_reader :multipliers

  NEGATIVE_EMOTIONS = %i[
    anger
    contempt
    disgust
    fear
    sadness
  ]
  POSITIVE_EMOTIONS = %i[
    happiness
    neutral
    surprise
  ]

  NORMALIZE_MULTIPLIER = NEGATIVE_EMOTIONS.count.to_f / POSITIVE_EMOTIONS.count.to_f

  def initialize(question_results)
    @question_results = question_results
    @multipliers = count_multipliers(emotion_results_by_interests)
  end

  def emotion_results_by_interests
    result = {}
    @question_results.each do |q_result|
      next if q_result.was_checked != 3
      question = q_result.question
      emotion_points = [q_result.emotion_state_result]
      result.merge!(question.picture.interests.map { |i| [i.name, emotion_points] }.to_h) do |_, old_emotion_points, new_emotion_points|
        old_emotion_points + new_emotion_points
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
      results_by_interests.transform_values do |emotion_result_array|
        emotion_states = emotion_result_array
                             .select { |emotion_state| emotion_state&.states.present? }
                             .flat_map { |emotion_state| emotion_state.states.values }
        next 0.0 if emotion_states.blank?
        total_states_count = emotion_states.count.to_f
        positive_emotions_count = emotion_states.select { |emotion_state| is_positive_state(emotion_state) }.count.to_f
        other_emotions_count = total_states_count - positive_emotions_count
        normalized_positive_emotion_count = positive_emotions_count * NORMALIZE_MULTIPLIER
        normalized_total_emotion_count = normalized_positive_emotion_count + other_emotions_count

        normalized_positive_emotion_count / normalized_total_emotion_count
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

    def is_positive_state(emotion_state)
      most_plausible_emotion = emotion_state
                                   .transform_values(&:to_f)
                                   .max_by { |_, probability| probability }
      POSITIVE_EMOTIONS.include?(most_plausible_emotion.first.to_sym)
    end
end
