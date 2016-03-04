class Administrator < ActiveRecord::Base
  has_many :tutors
  validates :organisation, presence: true, length: { in: 5..20}
  validates :is_super, presence: true
end
