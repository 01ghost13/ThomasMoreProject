# == Schema Information
#
# Table name: questions
#
#  id         :integer          not null, primary key
#  number     :integer
#  picture_id :integer
#  test_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class QuestionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "Empty fields" do
    question = Question.new
    assert question.invalid?
    assert question.errors[:test_id].any?
    assert question.errors[:picture_id].any?
    assert question.errors[:number].any?
  end
  test "Wrong Question number" do
    question = Question.new(test_id: 1, picture_id: 1, number: 0)
    assert question.invalid?
    assert question.errors[:number].any?, "Dont equal to zero"
    question_two = Question.new(test_id: 2, picture_id: 2, number: 0-1)
    #assert question_two.errors[:number].any?, "less than zero #{question_two.number}"
    question_three = Question.new(test_id: 3, picture_id: 3, number: 2/3)
    #assert question_three.errors[:number].any?, "Only integer #{question_three.number}"
  end
end
