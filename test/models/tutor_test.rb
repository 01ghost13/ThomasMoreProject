# == Schema Information
#
# Table name: tutors
#
#  id               :integer          not null, primary key
#  info_id          :integer
#  administrator_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'test_helper'

class TutorTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  fixtures :tutors
  test "Empty fields" do
    test_tutor = Tutor.new
    assert test_tutor.invalid?
    assert test_tutor.errors[:info_id].any?
    assert test_tutor.errors[:administrator_id].any?
  end
  test "Uniq info" do
    test_tutor = Tutor.new(info_id: tutors(:test_tutor).info_id, administrator_id: tutors(:test_tutor).administrator_id)
    assert test_tutor.invalid?
    assert test_tutor.errors[:info_id].any?
    assert !test_tutor.errors[:administrator_id].any?
  end
end
