class Picture < ActiveRecord::Base
  has_many :picture_interests
  has_many :interests, :through => :picture_interests
  has_many :questions
  validates :path, presence: true, length: {in: 5..40}
  validates :description, presence: true, length: {in: 5..50}
  
  def related_interests
    links = PictureInterest.where(picture_id: self.id)
    result = {}
    links.each do |link|
      result[Interest.find(link.interest_id).name] = link.earned_points
    end
    return result
  end
end
