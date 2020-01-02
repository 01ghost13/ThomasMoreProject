# == Schema Information
#
# Table name: questions
#
#  id              :integer          not null, primary key
#  number          :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  picture_id      :integer
#  test_id         :integer
#  youtube_link_id :bigint
#

class Question < ActiveRecord::Base
  #Probably better to use linked list
  before_destroy :on_destroy

  belongs_to :picture, inverse_of: :questions, optional: true
  belongs_to :youtube_link, inverse_of: :questions, optional: true
  belongs_to :test
  has_many :question_results, dependent: :nullify

  validates :test, presence: true
  validates :number, presence: true, numericality: { only_integer: true, greater_than: 0 }

  accepts_nested_attributes_for :youtube_link

  def youtube?
    youtube_link_id.present?
  end

  def attachment_description
    if picture_id.present?
      picture.description
    elsif youtube_link_id.present?
      youtube_link.description
    else
      ''
    end
  end

  private
    def on_destroy
      #Changes number of questions
      Question.where(['test_id = ? and number > ?', self.test_id, self.number]).each do |question|
        question.number -= 1
        question.save
      end
      #Setting results as outdated
      ResultOfTest.where(test_id: self.test_id).update_all(is_outdated: true)
    end
end
