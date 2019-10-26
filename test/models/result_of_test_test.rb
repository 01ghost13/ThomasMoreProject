# == Schema Information
#
# Table name: result_of_tests
#
#  id                  :integer          not null, primary key
#  was_in_school       :boolean
#  is_ended            :boolean
#  test_id             :integer
#  schooling_id        :integer
#  student_id          :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  is_outdated         :boolean          default(FALSE)
#  emotion_recognition :boolean          default(FALSE)
#  gaze_trace          :boolean          default(FALSE)
#

require 'test_helper'

class ResultOfTestTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "Empty fields" do
    res = ResultOfTest.new
    assert res.invalid?
    assert res.errors[:test_id].any?
    assert res.errors[:was_in_school].any?
    assert res.errors[:student_id].any?
    assert res.errors[:schooling_id].any?
    assert res.errors[:is_ended].any?
  end
end
