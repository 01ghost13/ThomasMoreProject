# == Schema Information
#
# Table name: modes
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Mode < ActiveRecord::Base
  has_many :clients
  validates :name, presence: true, uniqueness: true, length: {in: 5..20}
end
