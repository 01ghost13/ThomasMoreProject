class ResultOfTest < ActiveRecord::Base
  before_validation :setup_fields, on: :create

  belongs_to :test
  belongs_to :schooling
  belongs_to :student
  has_many :question_results, dependent: :destroy
  accepts_nested_attributes_for :question_results

  validates :test,:schooling,:student, presence: true
  validates :was_in_school, exclusion: { in: [nil] }

  def setup_fields
    self.is_ended = false
    self.is_outdated = false
    true
  end
  #Returns the question after last answered
  def last_question
    questions = QuestionResult.order(:number).where(result_of_test_id: self.id)
    Question.where("test_id = :test and number = :number",
                   {test: self.test_id, number:(questions.count == 0)? 1 :questions.count+1}).take
  end

  #Returns question before current
  def previous_question
    questions = QuestionResult.order(:number).where(result_of_test_id: self.id)
    Question.where("test_id = :test and number = :number",
                   {test: self.test_id, number:(questions.count == 0)? 1 :questions.count-1}).take
  end

  def show_short
    result_info = {date_of_start: self.created_at}  
    result_info[:name_of_test] = Test.find(self.test_id).name
    result_info[:id] = self.id
    result_info[:student_id] = self.student_id
    result_info[:is_ended] = self.is_ended
    result_info[:test_id] = self.test_id
    result_info[:date_of_end] = ''
    if is_ended?
      result_info[:date_of_end] = QuestionResult.order(:created_at).where(result_of_test_id: self.id).last.created_at
    end
    result_info[:is_outdated] = self.is_outdated
    result_info
  end
end
