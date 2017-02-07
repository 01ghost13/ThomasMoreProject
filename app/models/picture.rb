class Picture < ActiveRecord::Base
  has_many :picture_interests
  has_many :interests, :through => :picture_interests
  has_many :questions
  has_attached_file :image,
                    path: ':rails_root/public/system/:class/:id_:basename.:extension',
                    url: '/system/:class/:id_:basename.:extension'
  validates :path, presence: true, length: {in: 5..40}
  validates :description, presence: true, length: {in: 5..50}
  validates_attachment :image, presence: true, size: {less_than: 2.megabytes}
  validates_attachment_content_type :image, content_type: /\Aimage/
  validates_attachment_file_name :image, matches: [/png\z/, /jpe?g\z/]

  def related_interests
    links = PictureInterest.where(picture_id: self.id)
    result = {}
    links.each do |link|
      result[Interest.find(link.interest_id).name] = link.earned_points
    end
    result
  end
end
