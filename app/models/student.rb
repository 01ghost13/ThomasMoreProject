class Student < ActiveRecord::Base
  has_secure_password
  has_many :result_of_tests
  validates :codename, presence: true, uniqueness: true, length: { in: 6..20}
  validates :gender, presence: true, inclusion: { in: %w(1 2 3) }
  #0 – dunno
  #1 – Men
  #2 – Women

  validates :is_active,:is_current_in_school, presence: true
end
