class Administrator < ActiveRecord::Base
  has_many :tutors
  validates :organisation, presence: true, length: { in: 5..20}
  validates :is_super,:info_id, presence: true
  validates :is_super, uniqueness: true, if: "is_super == true"
  validates :info_id, uniqueness: true
end
