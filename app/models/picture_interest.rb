class PictureInterest < ActiveRecord::Base
  validates :number, numericality: { only_integer: true, greater_than: -1, less_than: 6 }
  validates :picture_id, :interest_id,:number, presence: true
end
