class Student < ActiveRecord::Base
  before_validation :setup_fields, on: :create
  has_secure_password
  has_many :result_of_tests
  belongs_to :tutor, inverse_of: :students
  belongs_to :schooling, inverse_of: :students
  #Validating
  validates :code_name, presence: true, uniqueness: true, length: { in: 6..20}
  validates :gender, presence: true, inclusion: { in: [1,2,3] }
  #1 – dunno
  #2 – Men
  #3 – Women
  validates :password_digest,:tutor_id,:schooling_id,:mode_id, presence: true
  validates :is_active, :is_current_in_school, exclusion: { in: [nil] }
  
  #Setups default fields
  def setup_fields
    self.is_active = true
    self.mode_id = Mode.all.first.id
  end
  
  #Creates map with info
  def show_info
    user_info = {Codename: self.code_name}
    #Adding gender
    if self.gender == 1
      #dunno
      user_info[:Gender] = 'Unknown'
    elsif self.gender == 2
      #men
      user_info[:Gender] = 'Men'
    else
      #women
      user_info[:Gender] = 'Women'
    end
    tutor = Tutor.find(self.tutor_id)
    user_info[:Tutor] = tutor.info.last_name+' '+tutor.info.name
    schooling = Schooling.find(self.schooling_id)
    user_info[:Schooling] = schooling.name
    user_info[:Current_in_school] = self.is_current_in_school ? 'Yes' : 'No'
    return user_info
  end
end
