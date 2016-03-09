class PictureInterest < ActiveRecord::Base
  validates :earned_points, numericality: { only_integer: true, greater_than: -1, less_than: 6 }
  validates :picture_id, :interest_id,:earned_points, presence: true
end
