# == Schema Information
#
# Table name: interests
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class InterestTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  fixtures :interests
  test "Empty fields" do
    i = Interest.new
    assert i.invalid?
    assert i.errors[:name].any?
  end
  test "Uniqueness" do
    i = Interest.new(name: interests(:test_inter).name)
    assert i.invalid?
    assert i.errors[:name].any?
  end
end
