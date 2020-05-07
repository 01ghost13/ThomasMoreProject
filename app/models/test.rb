# == Schema Information
#
# Table name: tests
#
#  id          :integer          not null, primary key
#  name        :string
#  description :string
#  version     :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Test < ActiveRecord::Base
  include TranslatableModels
  include Translatable

  define_translatable_columns %i[name description]

  scope :filter_by_availability, ->(user_id) { joins(:test_availabilities).where('test_availabilities.user_id': user_id, 'test_availabilities.available': true) }

  after_save :set_outdated

  after_create :fill_test_availability

  has_many :questions, inverse_of: :test, dependent: :destroy
  has_many :result_of_tests, dependent: :destroy
  has_many :test_availabilities, dependent: :destroy

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

  def fill_test_availability
    users = User.all_local_admins.ids

    users.each do |user|
      fill_test_availability.create(user_id: user.id, available: false)
    end
  end

  private
  #Sets results outdated if Test was changed
  def set_outdated
    #Setting results as outdated
    ResultOfTest.where(test_id: self.id).update_all(is_outdated: true)
  end
end
