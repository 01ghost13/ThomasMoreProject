# == Schema Information
#
# Table name: pictures
#
#  id          :integer          not null, primary key
#  description :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

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

  def small_variant
    image.variant(quality: 40, resize: '150x150')
  end

  def middle_variant
    image.variant(quality: 80, resize: '300x300')
  end

  #Returns all pictures
  def self.pictures_list
    Picture.with_attached_image.order(:description).map do |t|
      ["%{name}"%{name: t.description}, t.id]
    end
  end
end

