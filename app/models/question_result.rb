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
    {start: self.start, end: self.end, was_rewrited: self.was_rewrited, was_checked: self.was_checked,
     question_id: self.question_id }
  end

  def human_was_checked
    Array["Don't like", 'Skipped', 'Liked'][self.was_checked - 1]
  end

  private :setup_fields
end
