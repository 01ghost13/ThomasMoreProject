class Interest < ActiveRecord::Base
  has_many :points
  has_many :pictures, :through => :picture_interests
  validates :interest, presence: true, length: {in: 2..20}
end