class Interest < ActiveRecord::Base
  has_many :points
  has_many :point_last_results
  has_and_belongs_to_many :pictures
end
