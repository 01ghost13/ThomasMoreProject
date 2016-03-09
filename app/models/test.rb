class Test < ActiveRecord::Base
  has_many :questions
  has_many :result_of_tests
  validates :name,:description,:version, presence: true
  validates :name, uniqueness: true, length: {in: 5..20}
  validates :description, length: {in: 5..50}
  validates :version, numericality: true, length: {in: 1..10}
end
