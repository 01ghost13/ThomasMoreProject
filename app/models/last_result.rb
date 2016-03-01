class LastResult < ActiveRecord::Base
  belongs_to :student
  has_many :point_last_results
end
