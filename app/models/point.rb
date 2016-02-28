class Point < ActiveRecord::Base
  has_and_belongs_to_many :stats
  has_and_belongs_to_many :last_results
end
