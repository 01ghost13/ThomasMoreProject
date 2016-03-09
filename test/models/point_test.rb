require 'test_helper'

class PointTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "Empty fields" do
    pnt = Point.new
    assert pnt.invalid?
    assert pnt.errors[:interest_id].any?
    assert pnt.errors[:earned_points].any?
    assert pnt.errors[:result_of_test_id].any?
  end
  test "Count of Points" do
    pnt = Point.new(interest_id: 1, result_of_test_id: 1, earned_points: -5)
    assert pnt.invalid?
    assert pnt.errors[:earned_points].any?
  end
end
