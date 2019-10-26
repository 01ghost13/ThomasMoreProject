# == Schema Information
#
# Table name: schoolings
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Schooling < ActiveRecord::Base
  has_many :students
  has_many :result_of_tests
  validates :name, presence: true, uniqueness: true, length: { in:5..20 }
end
