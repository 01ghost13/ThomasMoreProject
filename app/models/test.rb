class Test < ActiveRecord::Base
  has_many :questions, inverse_of: :test
  has_many :result_of_tests
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
end
