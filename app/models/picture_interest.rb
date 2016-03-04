class PictureInterest < ActiveRecord::Base
  validates :number, presence: true, numericality: { only_integer: true, greater_than: -1, less_than: 6 }
end
