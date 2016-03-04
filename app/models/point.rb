class Point < ActiveRecord::Base
  validates :earned_points, presence: true, numericality: { only_integer: true, greater_than: -1}
end
