class ResultOfTest < ActiveRecord::Base
  before_validation :setup_fields, on: :create
  has_many :points
  has_many :question_results
  #validates :is_ended,:test_id,:schooling_id,:student_id, presence: true
  validates :was_in_school, exclusion: { in: [nil] }
  
  def setup_fields
    self.is_ended = false
    return true
  end
  #Returns the question after last answered
  def last_question
    questions = QuestionResult.order(:number).where(result_of_test_id: self.id)
    return Question.where("test_id = :test and number = :number", {test: self.test_id, number:(questions.count == 0)? 1 :questions.count+1}).take
  end
end
