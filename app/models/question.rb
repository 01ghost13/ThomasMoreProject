class Question < ActiveRecord::Base
  #Probably better to use linked list
  before_destroy :on_destroy
  belongs_to :picture, inverse_of: :questions
  belongs_to :test
  has_many :question_results, dependent: :nullify
  validates :test, :picture, presence: true
  validates :number, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :is_tutorial, exclusion: { in: [nil] }
  private
    def on_destroy
      Question.where(['test_id = ? and number > ?', self.test_id, self.number]).each do |question|
        question.number -= 1
        question.save
      end
    end
end
