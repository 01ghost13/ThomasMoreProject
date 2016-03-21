class Tutor < ActiveRecord::Base
  has_many :students
  belongs_to :info, inverse_of: :tutor
  accepts_nested_attributes_for :info
  validates :info_id, :administrator_id, presence: true
  validates :info_id, uniqueness: true
end
