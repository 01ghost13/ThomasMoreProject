# == Schema Information
#
# Table name: picture_interests
#
#  id            :integer          not null, primary key
#  earned_points :integer
#  picture_id    :integer
#  interest_id   :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'test_helper'

class PictureInterestTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "Empty fields" do
    pic_int = PictureInterest.new
    assert pic_int.invalid?
    assert pic_int.errors[:earned_points].any?
    assert pic_int.errors[:picture_id].any?
    assert pic_int.errors[:interest_id].any?
  end
  test "Points" do
    pic_int = PictureInterest.new(picture_id:1,interest_id:1,earned_points:-3)
    assert pic_int.invalid?
    assert pic_int.errors[:earned_points].any?
    pic_int = PictureInterest.new(picture_id:1,interest_id:1,earned_points:10)
    assert pic_int.invalid?
    assert pic_int.errors[:earned_points].any?
    pic_int = PictureInterest.new(picture_id:1,interest_id:1,earned_points:6)
    assert pic_int.invalid?
    assert pic_int.errors[:earned_points].any?
    pic_int = PictureInterest.new(picture_id:1,interest_id:1,earned_points:-1)
    assert pic_int.invalid?
    assert pic_int.errors[:earned_points].any?
    
  end
end
