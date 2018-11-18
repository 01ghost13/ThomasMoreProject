class Picture < ActiveRecord::Base
  has_many :picture_interests, inverse_of: :picture, dependent: :destroy
  has_many :interests, :through => :picture_interests
  has_many :questions, dependent: :destroy

  has_one_attached :image
  accepts_nested_attributes_for :picture_interests, reject_if: :all_blank, allow_destroy: true

  validates :description, presence: true, length: {in: 5..50}
  validates :picture_interests, nested_attributes_uniqueness: {field: :interest_id}

  #returns related interests to a picture
  def related_interests
    links = PictureInterest.where(picture_id: self.id)
    result = {}
    links.each do |link|
      result[Interest.find(link.interest_id).name] = link.earned_points
    end
    result
  end

  #Returns all pictures
  def self.pictures_list
    Picture.order(:image_file_name).map {
        |t| ["%{name}"%{name: t.image_file_name},t.id]
    }
  end
end

