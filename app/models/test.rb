class Test < ActiveRecord::Base
  after_save :set_outdated

  has_many :questions, inverse_of: :test, dependent: :delete_all
  has_many :result_of_tests, dependent: :restrict_with_error
  accepts_nested_attributes_for :questions, reject_if: :all_blank, allow_destroy: true

  validates :name,:description,:version, presence: true
  validates :name, uniqueness: true, length: {in: 5..20}
  validates :description, length: {in: 5..50}
  validates :version, numericality: true, length: {in: 1..10}

  def show_short
    test_info = {name: self.name.titleize}
    test_info[:version] = self.version
    test_info[:id] = self.id
    test_info[:question_count] = Question.where(test_id: self.id).count
    test_info[:description] = self.description
    test_info
  end
  private
    def set_outdated
      #Setting results as outdated
      ResultOfTest.where(test_id: self.id).update_all(is_outdated: true)
    end
end
