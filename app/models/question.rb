class Question < ActiveRecord::Base
  validates :is_tutorial, presence: true
  validates :number, presence: true, numericality: { only_integer: true, greater_than: 0 }
end
