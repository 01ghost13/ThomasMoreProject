class QuestionResult < ActiveRecord::Base
  before_validation :setup_fields, on: :create
  belongs_to :question
  belongs_to :result_of_test
  validates :number, presence: true, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :start, :end, :result_of_test, presence: true
  validates :was_checked, inclusion: { in: [1,2,3] }
  # 1 - td
  # 2 - qm 
  # 3 - tu
  validates :was_rewrited, exclusion: { in: [nil]}
  validates :question, presence: true, allow_nil: true
  def setup_fields
    self.was_rewrited = false
    self.end = DateTime.current
    true
  end
  def show
    {start: self.start, end: self.end, was_rewrited: self.was_rewrited, was_checked: self.was_checked,
     question_id: self.question_id }
  end
end
