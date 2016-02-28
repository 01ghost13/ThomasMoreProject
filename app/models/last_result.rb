class LastResult < ActiveRecord::Base
  belongs_to :student
  has_and_belongs_to_many :points
end
