# == Schema Information
#
# Table name: result_of_tests
#
#  id                  :integer          not null, primary key
#  emotion_recognition :boolean          default(FALSE)
#  gaze_trace          :boolean          default(FALSE)
#  is_ended            :boolean
#  is_outdated         :boolean          default(FALSE)
#  was_in_school       :boolean
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  client_id           :integer
#  test_id             :integer
#

class ResultOfTest < ActiveRecord::Base
  before_validation :setup_fields, on: :create

  belongs_to :test
  belongs_to :client

  has_many :question_results, dependent: :destroy

  accepts_nested_attributes_for :question_results

  scope :result_page, -> { includes(:question_results, question_results: [:question, question: [:picture]]) }

  validates :test, :client, presence: true
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
    result_info[:client_id] = self.client_id
    result_info[:user_id] = client.user.id
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

  def show_emotion_dynamic
    list = {}
    r = Random.new
    question_results.map(&:get_emotion_lists).each_with_index do |question_emotions, i|
      list.merge!(question_emotions.transform_values { |emo_arr| emo_arr.map { |emo_v| [r.rand(i.to_f), emo_v] } }) do |_, a, b|
        a + b
      end
    end
    list
  end

  def show_plausible_emotion_states_dynamic
    list = {}
    r = Random.new
    question_results.map(&:get_plausible_emotion_states).each_with_index do |question_emotions, i|
      step = 1.0 / question_emotions.count
      question_emotions.each_with_index do |q_e, j|
        list.merge!({q_e.first => [[i + 1 + step * j, q_e.second.to_f]]}) do |_, a, b|
        # list.merge!({q_e.first => [[r.rand(i.to_f), q_e.second.to_f]]}) do |_, a, b|
          a + b
        end
      end
    end
    list
  end

  def average_inside_picture
    gaze_results = question_results.includes(:gaze_trace_result).map do |qr|
      qr.gaze_trace_result
    end
    sum = gaze_results
              .select { |gr| gr.gaze_points.present? }
              .map { |gr| gr.inside_picture_points.count / gr.gaze_points.count.to_f }
              .reduce(&:+)
    total = gaze_results.count.to_f
    sum / total
  end

  def average_inside_buttons
    gaze_results = question_results.includes(:gaze_trace_result).map do |qr|
      qr.gaze_trace_result
    end
    sum = gaze_results
              .select { |gr| gr.gaze_points.present? }
              .map { |gr| gr.inside_buttons_points.count / gr.gaze_points.count.to_f }
              .reduce(&:+)
    total = gaze_results.count.to_f
    sum / total
  end

  def without_gazes
    gaze_results = question_results.includes(:gaze_trace_result).map do |qr|
      qr.gaze_trace_result
    end
    gaze_results.select { |gr| gr.gaze_points.blank? }.count
  end

  def without_emotions
    emotion_states = question_results.includes(:emotion_state_result).map(&:emotion_state_result)
    emotion_states.select { |es| es&.states.blank? }.count
  end

  def correlates_with_positive
    EmotionMultiplierCalculator.new(question_results).correlates_with_positive_emotion.count / question_results.count.to_f
  end

  def correlates_with_negative
    EmotionMultiplierCalculator.new(question_results).correlates_with_negative_emotion.count / question_results.count.to_f
  end

  def count_neutral
    EmotionMultiplierCalculator.new(question_results).neutral_states.count / question_results.count.to_f
  end

  def clear_dups_es
    all_esr = question_results.map(&:emotion_state_result)
    checked_states = []
    all_esr.each do |esr|
      emotion_states = esr.states.values
      values_to_save = emotion_states.select { |emotion_state| checked_states.find_index(emotion_state).blank? }
      checked_states += values_to_save
      esr.states = values_to_save.map.with_index { |v, i| [i, v] }.to_h
    end
  end

  def progress
    answered_count = question_results.count
    total = test.questions.count
    [answered_count, total]
  end

  private :setup_fields
end
