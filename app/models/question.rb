class Question < ActiveRecord::Base
  belongs_to :picture, inverse_of: :questions
  validates :test_id, :picture_id, presence: true
  validates :number, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :is_tutorial, exclusion: { in: [nil] }
end
