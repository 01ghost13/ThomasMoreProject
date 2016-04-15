class Interest < ActiveRecord::Base
  has_many :picture_interests
  has_many :points
  has_many :pictures, :through => :picture_interests
  validates :name, uniqueness: true, presence: true, length: {in: 2..20}
end
