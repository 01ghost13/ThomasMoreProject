class Tutor < ActiveRecord::Base
  has_many :students
  validates :info_id, :administrator_id, presence: true
  validates :info_id, uniqueness: true
end
