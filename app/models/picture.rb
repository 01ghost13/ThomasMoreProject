class Picture < ActiveRecord::Base
  has_many :interests, :through => :picture_interests
  has_many :questions
  validates :path, presence: true, length: {in: 5..40}
  validates :description, presence: true, length: {in: 5..50}
end
