class QuestionResult < ActiveRecord::Base
  before_validation :setup_fields, on: :create
  validates :number, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :start, :end, :result_of_test_id, presence: true
  validates :was_checked, inclusion: { in: [1,2,3] }
  # 1 - td
  # 2 - qm 
  # 3 - tu
  validates :was_rewrited, exclusion: { in: [nil]}
  
  def setup_fields
    self.was_rewrited = false
    self.end = DateTime.current
  end
end
