class Schooling < ActiveRecord::Base
  has_many :students
  has_many :result_of_tests
  validates :name, presence: true, uniqueness: true, length: { in:5..20 }
end
