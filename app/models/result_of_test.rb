class ResultOfTest < ActiveRecord::Base
  has_many :points
  has_many :question_results
  validates :was_in_school,:is_ended,:test_id,:schooling_id,:student_id presence: true
end
