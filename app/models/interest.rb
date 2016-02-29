class Interest < ActiveRecord::Base
  has_many :points
  has_and_belongs_to_many :pictures
end
