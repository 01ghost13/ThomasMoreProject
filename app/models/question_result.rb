class QuestionResult < ActiveRecord::Base
  validates :number, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :start, :end, :was_rewrited, :was_checked,:result_of_test_id, presence: true
end
