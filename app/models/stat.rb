class Stat < ActiveRecord::Base
  has_one :student
  has_many :points
end
