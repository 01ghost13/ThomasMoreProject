class Picture < ActiveRecord::Base
  has_and_belongs_to_many :interests
  has_and_belongs_to_many :questions
end
