# == Schema Information
#
# Table name: emotion_state_results
#
#  id         :bigint           not null, primary key
#  states     :json
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class EmotionStateResult < ActiveRecord::Base

  # Array of values for each emotion
  def emotion_lists
    states.values.reduce({}) do |sum_hash, current_state|
      state_to_add = current_state.transform_values { |v| [v.to_f.round(3)] }
      sum_hash.merge(state_to_add) { |_, a, b| a + b }
    end
  end

  def plausible_emotion_states_list
    states.values.map do |emotion_state|
      emotion_state.max_by { |emo_v_a| emo_v_a.second.to_f }
    end
  end
end
