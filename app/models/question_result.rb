# == Schema Information
#
# Table name: question_results
#
#  id                      :integer          not null, primary key
#  number                  :integer
#  start                   :datetime
#  end                     :datetime
#  was_rewrited            :boolean
#  result_of_test_id       :integer
#  was_checked             :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  question_id             :integer
#  gaze_trace_result_id    :bigint
#  emotion_state_result_id :bigint
#

class QuestionResult < ActiveRecord::Base
  before_validation :setup_fields, on: :create

  belongs_to :question
  belongs_to :result_of_test
  belongs_to :gaze_trace_result, optional: true
  belongs_to :emotion_state_result, optional: true

  accepts_nested_attributes_for :gaze_trace_result
  accepts_nested_attributes_for :emotion_state_result

  validates :number, presence: true, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :start, :end, :result_of_test, presence: true
  validates :was_checked, inclusion: { in: [1,2,3] }
  # 1 - thumbs down (don't like)
  # 2 - question mark (skip)
  # 3 - thumbs up (do like)
  validates :was_rewrited, exclusion: { in: [nil]}
  validates :question, presence: true, allow_nil: true

  #Setups default fields
  def setup_fields
    self.was_rewrited = false
    self.end = DateTime.current
    true
  end

  #Shows question result
  def show
    {
      start: self.start,
      end: self.end,
      was_rewrited: self.was_rewrited,
      was_checked: self.was_checked,
      question_id: self.question_id
    }
  end

  def human_was_checked
    Array["Don't like", 'Skipped', 'Liked'][self.was_checked - 1]
  end

  def get_emotion_lists
    return {} if emotion_state_result.blank?
    emotion_state_result.emotion_lists
  end

  def get_plausible_emotion_states
    return [] if emotion_state_result.blank?
    emotion_state_result.plausible_emotion_states_list
  end

  def total_time
    self.end - self.start
  end

  private :setup_fields
end
