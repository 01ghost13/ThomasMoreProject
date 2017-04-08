class PictureInterest < ActiveRecord::Base
  belongs_to :interest
  belongs_to :picture
  validates :earned_points, numericality: { only_integer: true, greater_than: -1, less_than: 6 }
  #TODO: Change tutor_id -> tutor etc
  validates :interest,:earned_points, presence: true
  validates_presence_of :picture
  validates_associated :picture, allow_blank: true
  #validate :uniqueness_interests
  validates_uniqueness_of :interest_id, scope: :picture_id

end
