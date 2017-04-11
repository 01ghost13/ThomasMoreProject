class Picture < ActiveRecord::Base
  has_many :picture_interests, inverse_of: :picture, dependent: :destroy
  has_many :interests, :through => :picture_interests
  accepts_nested_attributes_for :picture_interests, reject_if: :all_blank, allow_destroy: true
  has_many :questions, dependent: :destroy
  has_attached_file :image,
                    path: ':class/:style/:id_:hash.:extension',
                    url: '/:class/:style/:id_:hash.:extension',
                    hash_secret: 'TWILIGHT_IS_BEST_PONY',
                    styles: {thumb: ['40%']},
                    storage: :cloudinary

  validates :description, presence: true, length: {in: 5..50}
  validates_attachment :image, presence: true, size: {less_than: 2.megabytes}
  validates_attachment_content_type :image, content_type: /\Aimage/
  validates_attachment_file_name :image, matches: [/png\z/, /jpe?g\z/]
  validates :picture_interests, nested_attributes_uniqueness: {field: :interest_id}

  def related_interests
    links = PictureInterest.where(picture_id: self.id)
    result = {}
    links.each do |link|
      result[Interest.find(link.interest_id).name] = link.earned_points
    end
    result
  end

  def self.pictures_list
    pictures = Picture.order(:image_file_name).map {
        |t| ["%{name}"%{name: t.image_file_name},t.id]
    }
  end
end

