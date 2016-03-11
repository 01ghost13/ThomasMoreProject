class QuestionResult < ActiveRecord::Base
  validates :number, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :start, :end, :result_of_test_id, presence: true
  validates :was_checked, inclusion: { in: [1,2,3] }
  validates :was_rewrited, exclusion: { in: [nil]}
end
