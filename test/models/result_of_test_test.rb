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
