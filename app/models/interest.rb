class Interest < ActiveRecord::Base
  has_many :picture_interests
  has_many :points
  has_many :pictures, :through => :picture_interests
  validates :name, uniqueness: true, presence: true, length: {in: 2..25}
  before_destroy do
    #delete all entries in picture_interests
    PictureInterest.where(interest_id: self.id).destroy_all
  end
end
