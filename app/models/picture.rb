class Picture < ActiveRecord::Base
  before_destroy :mark_outdated

  has_many :picture_interests, inverse_of: :picture, dependent: :destroy
  has_many :interests, :through => :picture_interests
  accepts_nested_attributes_for :picture_interests, reject_if: :all_blank, allow_destroy: true
  has_many :questions, dependent: :destroy
  has_attached_file :image,
                    path: ':rails_root/public/system/:class/:style/:id_:basename.:extension',
                    url: '/system/:class/:style/:id_:basename.:extension',
                    styles: {thumb: ['40%']}
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
  private
  def mark_outdated
    #Setting results as outdated
    q = Question.where(picture_id: self.id)
    ResultOfTest.where(test_id: q.select(:test_id)).update_all(is_outdated: true)
  end
end
