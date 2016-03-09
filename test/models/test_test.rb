require 'test_helper'

class TestTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  fixtures :tests
  test 'Empty fields' do
    some_test = Test.new
    assert some_test.invalid?
    assert some_test.errors[:name].any?
    assert some_test.errors[:description].any?
    assert some_test.errors[:version].any?
  end
  test 'Uniq name' do
    some_test = Test.new(name: tests(:first_test).name, description: 'blablalab', version: '1.0')
    assert some_test.invalid?
    assert some_test.errors[:name].any?
  end
end
