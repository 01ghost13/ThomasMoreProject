class ResultOfTest < ActiveRecord::Base
  before_validation :setup_fields, on: :create
  has_many :points
  has_many :question_results
  accepts_nested_attributes_for :question_results
  validates :test_id,:schooling_id,:student_id, presence: true
  validates :was_in_school, exclusion: { in: [nil] }
  
  def setup_fields
    self.is_ended = false
    true
  end
  #Returns the question after last answered
  def last_question
    questions = QuestionResult.order(:number).where(result_of_test_id: self.id)
    Question.where("test_id = :test and number = :number", {test: self.test_id, number:(questions.count == 0)? 1 :questions.count+1}).take
  end
  #Returns question before current
  def previous_question
    questions = QuestionResult.order(:number).where(result_of_test_id: self.id)
    Question.where("test_id = :test and number = :number", {test: self.test_id, number:(questions.count == 0)? 1 :questions.count-1}).take
  end
  def show_short
    result_info = {date_of_start: self.created_at}  
    result_info[:name_of_test] = Test.find(self.test_id).name
    result_info[:id] = self.id
    result_info[:student_id] = self.student_id
    result_info[:is_ended] = self.is_ended ? 'Yes' : 'No'
    result_info
  end
end
