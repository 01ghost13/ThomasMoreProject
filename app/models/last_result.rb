class LastResult < ActiveRecord::Base
  has_one :student
  has_many :point_last_results
end
