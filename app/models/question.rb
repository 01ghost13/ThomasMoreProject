class Question < ActiveRecord::Base
  validates :is_tutorial, :test_id, :picture_id, presence: true
  validates :number, presence: true, numericality: { only_integer: true, greater_than: 0 }
end
