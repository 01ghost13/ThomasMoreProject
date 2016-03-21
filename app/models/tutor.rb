class Tutor < ActiveRecord::Base
  has_many :students
  validates :info_id, :administrator_id, presence: true
  validates :info_id, uniqueness: true
  belongs_to :info, inverse_of: :tutor
end
