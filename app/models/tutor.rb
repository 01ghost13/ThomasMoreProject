class Tutor < ActiveRecord::Base
  has_many :students, inverse_of: :tutor
  belongs_to :info, inverse_of: :tutor, validate: true
  accepts_nested_attributes_for :info
  validates :info_id, :administrator_id, presence: true
  validates :info_id, uniqueness: true
  
  #Shows info of tutor as a map
  def show
    user_info = self.info.show
    adm = Administrator.find(self.administrator_id)
    info_adm = adm.info
    user_info[:administrator] = info_adm.name + " " + info_adm.last_name
    user_info[:organisation] = adm.organisation
    return user_info
  end
  def is_my_student? (student_id)
    student = Student.find(student_id)
    return false if student.nil?
    return student.tutor_id == self.id
  end
end
