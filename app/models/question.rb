class Question < ActiveRecord::Base
  #Probably better to use linked list
  belongs_to :picture, inverse_of: :questions
  validates :test_id, :picture_id, presence: true
  validates :number, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :is_tutorial, exclusion: { in: [nil] }
  before_destroy do
    Question.where(['test_id = ? and number > ?', self.test_id, self.number]).each do |question|
      question.number -= 1
      question.save
    end
    #QuestionResult.where(['test_id = ? and number = ?', self.test_id, self.number]).update_all(number: nil)
  end
end
