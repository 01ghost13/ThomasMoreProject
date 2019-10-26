# == Schema Information
#
# Table name: students
#
#  id                   :integer          not null, primary key
#  code_name            :string
#  birth_date           :date
#  date_off             :date
#  gender               :integer
#  adress               :string
#  is_active            :boolean
#  password_digest      :string
#  is_current_in_school :boolean
#  schooling_id         :integer
#  tutor_id             :integer
#  mode_id              :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  emotion_recognition  :boolean          default(FALSE)
#  gaze_trace           :boolean          default(FALSE)
#

require 'test_helper'

class StudentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  fixtures :students
  test "Empty fields" do
    stu = Student.new
    assert stu.invalid?
    assert stu.errors[:tutor_id].any?
    assert stu.errors[:code_name].any?
    assert stu.errors[:gender].any?
    assert stu.errors[:is_active].any?
    assert stu.errors[:password_digest].any?
    assert stu.errors[:is_current_in_school].any?
    assert stu.errors[:schooling_id].any?
    assert !stu.errors[:birth_date].any?
    assert !stu.errors[:date_off].any?
  end
  test "Unique code name" do
    stu = Student.new(
    tutor_id: 1,
    code_name: students(:test_student).code_name,
    gender: 2,
    is_active: true,
    password_digest: '0206950',
    mode_id: 2,
    schooling_id: 1,
    is_current_in_school: false)
    assert stu.invalid?
    assert stu.errors[:code_name].any?, 'CodeName must be unique'
  end
  test "Another gender" do
    stu = Student.new(
    tutor_id: 1,
    code_name: 'nameOfStu',
    gender: -5,
    is_active: true,
    password_digest: '0206950',
    mode_id: 2,
    schooling_id: 1,
    is_current_in_school: false)
    assert stu.invalid?
    assert stu.errors[:gender].any?
  end
end
