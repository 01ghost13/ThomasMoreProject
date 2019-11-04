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
    assert res.errors[:client_id].any?
    assert res.errors[:is_ended].any?
  end
end
