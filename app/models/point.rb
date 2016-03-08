class Point < ActiveRecord::Base
  validates :earned_points, numericality: { only_integer: true, greater_than: -1}
  validates :interest_id, :result_of_test_id, :earned_points, presence: true
end
