# == Schema Information
#
# Table name: youtube_links
#
#  id          :bigint           not null, primary key
#  description :string
#  link        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class YoutubeLink < ActiveRecord::Base
  has_many :picture_interests, inverse_of: :picture, dependent: :destroy
  has_many :interests, :through => :picture_interests
  has_many :questions

  accepts_nested_attributes_for :picture_interests, reject_if: :all_blank, allow_destroy: true

  validates :link, presence: true
  validate :link_pattern

  # https://www.youtube.com/embed/oHg5SJYRHA0?autoplay=1&loop=1
  def embed
    regex = if 'youtu.be'.in?(link)
              # https://youtu.be/IhTXDklRLME
              /(?<=youtu\.be\/)[\w-]+\/?$/
            elsif 'youtube.com'.in?(link)
              # https://m.youtube.com/watch?v=IhTXDklRLME
              # https://www.youtube.com/watch?v=IhTXDklRLME
              /(?<=watch\?v=)[\w-]+\/?$/
            end

    return if regex.blank?

    result = regex.match(link)

    return if result.blank?

    "https://www.youtube.com/embed/#{result[0]}?autoplay=1&loop=1&&playlist=#{result[0]}&rel=0"
  end

  #returns related interests to a picture
  def related_interests
    links = PictureInterest.where(youtube_link_id: id)
    result = {}
    links.each do |link|
      result[Interest.find(link.interest_id).name] = link.earned_points
    end
    result
  end

  private
    def link_pattern
      return if link.blank?

      regex = /https:\/\/(www\.)?(((m\.)?youtube\.com\/watch\?v=[\w-]+)|(youtu\.be\/[\w-]+))\/?$/
      unless regex =~ link
        errors.add(:link, :link_pattern)
      end
    end
end
