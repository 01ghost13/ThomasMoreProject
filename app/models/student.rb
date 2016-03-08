class Student < ActiveRecord::Base
  has_secure_password
  has_many :result_of_tests
  validates :code_name, presence: true, uniqueness: true, length: { in: 6..20}
  validates :gender, presence: true, inclusion: { in: %w(1 2 3) }
  #1 – dunno
  #2 – Men
  #3 – Women

  validates :is_active,:is_current_in_school,:password_digest,:tutor_id,:schooling_id,:mode_id, presence: true
end
