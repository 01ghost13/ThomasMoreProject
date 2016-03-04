class Mode < ActiveRecord::Base
  has_many :students
  validates :name, presence: true, length: {in: 5..20}
end
