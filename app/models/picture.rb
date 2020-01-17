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
  validate :image_validation

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
    opts =
        if gif?
          { coalesce: true, quality: 40, resize: '150x150' }
        else
          { quality: 40, resize: '150x150' }
        end
    image.variant(opts)
  end

  def middle_variant
    # was 80%, 300x300 - too blurry
    opts =
        if gif?
          { coalesce: true, quality: 90, resize: '550x550' }
        else
          { quality: 90, resize: '550x550' }
        end
    image.variant(opts)
  end

  #Returns all pictures
  def self.pictures_list
    Picture.with_attached_image.order(:description).map do |t|
      ["%{name}"%{name: t.description}, t.id]
    end
  end

  def gif?
    image.blob.content_type.starts_with?('image/gif')
  end

  def image?
    !gif?
  end

  private
    def image_validation
      if image.attached?
        unless image.blob.content_type.starts_with?('image/')
          image.purge
          errors[:base] << 'Attachment must be image or gif'
        end
        if image.blob.byte_size > 3.megabytes
          image.purge
          errors[:base] << 'Attachment is too big'
        end
      end
    end
end

