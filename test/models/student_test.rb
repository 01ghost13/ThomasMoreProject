# == Schema Information
#
# Table name: clients
#
#  id                   :integer          not null, primary key
#  address              :string
#  birth_date           :date
#  code_name            :string
#  date_off             :date
#  emotion_recognition  :boolean          default(FALSE)
#  gaze_trace           :boolean          default(FALSE)
#  gender               :integer
#  is_active            :boolean
#  is_current_in_school :boolean
#  password_digest      :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  mode_id              :integer
#  tutor_id             :integer
#

require 'test_helper'

class ClientTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  fixtures :clients
  test "Empty fields" do
    stu = Client.new
    assert stu.invalid?
    assert stu.errors[:tutor_id].any?
    assert stu.errors[:code_name].any?
    assert stu.errors[:gender].any?
    assert stu.errors[:is_active].any?
    assert stu.errors[:password_digest].any?
    assert stu.errors[:is_current_in_school].any?
    assert !stu.errors[:birth_date].any?
    assert !stu.errors[:date_off].any?
  end
  test "Unique code name" do
    stu = Client.new(
    tutor_id: 1,
    code_name: clients(:test_client).code_name,
    gender: 2,
    is_active: true,
    password_digest: '0206950',
    mode_id: 2,
    is_current_in_school: false)
    assert stu.invalid?
    assert stu.errors[:code_name].any?, 'CodeName must be unique'
  end
  test "Another gender" do
    stu = Client.new(
    tutor_id: 1,
    code_name: 'nameOfStu',
    gender: -5,
    is_active: true,
    password_digest: '0206950',
    mode_id: 2,
    is_current_in_school: false)
    assert stu.invalid?
    assert stu.errors[:gender].any?
  end
end
