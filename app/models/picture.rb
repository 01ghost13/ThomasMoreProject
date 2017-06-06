class Picture < ActiveRecord::Base
  has_many :picture_interests, inverse_of: :picture, dependent: :destroy
  has_many :interests, :through => :picture_interests
  accepts_nested_attributes_for :picture_interests, reject_if: :all_blank, allow_destroy: true
  has_many :questions, dependent: :destroy
  #Settigns for production
  has_attached_file :image,
                    path: ':class/:style/:id_:hash.:extension',
                    url: '/:class/:style/:id_:hash.:extension',
                    hash_secret: 'TWILIGHT_IS_BEST_PONY',
                    styles: {thumb: ['40%']},
                    storage: :cloudinary if Rails.env.production?
  #Settings for dev
  has_attached_file :image,
                    path: ':rails_root/public/system/:class/:style/:id_:hash.:extension',
                    url: '/system/:class/:style/:id_:hash.:extension',
                    hash_secret: 'TWILIGHT_IS_BEST_PONY',
                    styles: {thumb: ['40%']} if Rails.env.development?


  validates :description, presence: true, length: {in: 5..50}
  validates_attachment :image, presence: true, size: {less_than: 2.megabytes}
  validates_attachment_content_type :image, content_type: /\Aimage/
  validates_attachment_file_name :image, matches: [/png\z/, /jpe?g\z/]
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

