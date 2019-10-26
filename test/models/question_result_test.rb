# == Schema Information
#
# Table name: question_results
#
#  id                      :integer          not null, primary key
#  number                  :integer
#  start                   :datetime
#  end                     :datetime
#  was_rewrited            :boolean
#  result_of_test_id       :integer
#  was_checked             :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  question_id             :integer
#  gaze_trace_result_id    :bigint
#  emotion_state_result_id :bigint
#

require 'test_helper'

class QuestionResultTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "Empty fields" do
    question = QuestionResult.new
    assert question.invalid?
    assert question.errors[:number].any?
    assert question.errors[:start].any?
    assert question.errors[:end].any?
    assert question.errors[:result_of_test_id].any?
    assert question.errors[:was_rewrited].any?
    assert question.errors[:was_checked].any?
  end
  test "Wrong Question number" do
    question = QuestionResult.new(number: 0, start: DateTime.current, :end => DateTime.current, was_rewrited: false, result_of_test_id: 1, was_checked: true)
    assert question.invalid?
    assert question.errors[:number].any?, "Dont equal to zero"
    question_two = QuestionResult.new(number:-1, start: DateTime.current, :end => DateTime.current, was_rewrited: false, result_of_test_id: 1, was_checked: true)
    #assert question_two.errors[:number].any?, "less than zero #{question_two.number}"
    question_three = QuestionResult.new(number:1.5, start: DateTime.current, :end => DateTime.current, was_rewrited: false, result_of_test_id: 1, was_checked: true)
    #assert question_three.errors[:number].any?, "Only integer #{question_three.number}"
  end
end
