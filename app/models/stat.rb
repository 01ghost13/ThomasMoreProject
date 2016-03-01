class Stat < ActiveRecord::Base
  belongs_to :student
  has_many :points
end
