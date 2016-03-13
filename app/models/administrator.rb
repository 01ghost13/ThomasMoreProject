class Administrator < ActiveRecord::Base
  has_many :tutors
  belongs_to :info, inverse_of: :administrator
  validates :organisation, presence: true, length: { in: 5..20}
  validates :info_id, presence: true, uniqueness: true
  validates :is_super, uniqueness: true, if: "is_super == true"
  validates :is_super, exclusion: { in: [nil] }
end
