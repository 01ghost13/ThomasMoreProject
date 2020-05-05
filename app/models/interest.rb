# == Schema Information
#
# Table name: interests
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Interest < ActiveRecord::Base
  include TranslatableModels
  include Translatable

  define_translatable_columns %i[name]

  has_many :picture_interests
  has_many :pictures, :through => :picture_interests

  validates :name, uniqueness: true, presence: true, length: { in: 5..100 }

  before_destroy do
    #delete all entries in picture_interests
    PictureInterest.where(interest_id: self.id).destroy_all
  end

  #returns list of all interests
  def self.interests_list
    Interest.order(:name).map {
        |t| ["%{name}"%{name: t.name.titleize},t.id]
    }
  end

  def self.interests_hash
    Interest.order(:name).map do |t|
      {name: t.name.titleize, id: t.id}
    end
  end
end
