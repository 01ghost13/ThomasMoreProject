# == Schema Information
#
# Table name: picture_interests
#
#  id              :integer          not null, primary key
#  earned_points   :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  interest_id     :integer
#  picture_id      :integer
#  youtube_link_id :bigint
#

class PictureInterest < ActiveRecord::Base
  #Joins table Picture and Interest for many-to-many
  belongs_to :interest
  belongs_to :picture, optional: true
  belongs_to :youtube_link, optional: true

  validates :earned_points, numericality: { only_integer: true, greater_than: -1, less_than: 6 }
  validates :interest,:earned_points, presence: true
  validates_associated :picture, allow_blank: true
  validates_associated :youtube_link, allow_blank: true
  validates_uniqueness_of :interest_id, scope: :picture_id
  validate :belongings

  private
    def belongings
      if picture.blank? && youtube_link.blank?
        errors[:base] << 'You need specify either picture or youtube link'
      end
    end
end
