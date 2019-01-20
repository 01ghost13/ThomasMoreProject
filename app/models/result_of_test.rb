class ResultOfTest < ActiveRecord::Base
  before_validation :setup_fields, on: :create

  belongs_to :test
  belongs_to :schooling
  belongs_to :student
  has_many :question_results, dependent: :destroy
  accepts_nested_attributes_for :question_results

  scope :result_page, -> { includes(:question_results, question_results: [:question, question: [:picture]]) }

  validates :test,:schooling,:student, presence: true
  validates :was_in_school, exclusion: { in: [nil] }

  #Setups default fields
  def setup_fields
    self.is_ended = false
    self.is_outdated = false
    true
  end

  #Returns the question after last answered
  def last_question
    questions = QuestionResult.order(:number).where(result_of_test_id: self.id)
    Question.where(test_id: self.test_id, number: (questions.count == 0) ? 1 : questions.count + 1).first
  end

  def get_question(number)
    get_question_result(number).question
  end

  def get_question_result(number)
    QuestionResult.includes(:question).where(result_of_test_id: self.id, number: number).first
  end

  #Returns question before current
  def previous_question
    questions = QuestionResult.order(:number).where(result_of_test_id: self.id)
    previous_number = (questions.count <= 1) ? 1 : questions.count - 1
    Question.where(test_id: self.test_id, number: previous_number).first
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

  def show_time_to_answer
    timeline = {}
    results = QuestionResult.order(:number).where(result_of_test_id: self.id)
    results.each do |r|
      timeline[r.number] = r.end - r.start
    end
    timeline
  end

  def show_timeline
    timeline = []
    duration = 0
    results = QuestionResult.order(:number).where(result_of_test_id: self.id)
    results.each do |r|
      timeline << [r.human_was_checked, duration, duration + (r.end - r.start)]
      duration += r.end - r.start
    end
    timeline
  end

  private :setup_fields
end
