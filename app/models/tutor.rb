class Tutor < ActiveRecord::Base
  has_many :students, inverse_of: :tutor, dependent: :restrict_with_error
  belongs_to :info, inverse_of: :tutor, autosave: true, dependent: :destroy
  
  validates :administrator_id, presence: true
  validates :info_id, uniqueness: true

  validates_presence_of :info
  validates_associated :info, allow_blank: true
  accepts_nested_attributes_for :info
  accepts_nested_attributes_for :students

  #Shows info of tutor as a map
  def show
    user_info = self.info.show
    adm = Administrator.find(self.administrator_id)
    info_adm = adm.info
    user_info[:administrator] = info_adm.name + ' ' + info_adm.last_name
    user_info[:organisation] = adm.organisation
    user_info
  end
  def is_my_student? (student_id)
    student = Student.find(student_id)
    return false if student.nil?
    student.tutor_id == self.id
  end
  def show_short
    user_info = self.info.show_short
    user_info[:id] = self.id
    adm = Administrator.find(self.administrator_id)
    user_info[:administrator] = adm.show_short
    user_info
  end
  def self.tutors_list (administrator_id)
    tutors = Tutor.where(administrator_id: administrator_id).order(:id).map {
        |t| ['%{mail}: %{lname} %{name}'%{mail: t.info.mail, lname: t.info.last_name, name: t.info.name},t.id]
    }
  end
  def other_tutors
    tutors = Tutor.where.not(id: self.id).order(:id).map {
        |t| ['%{mail}: %{lname} %{name}'%{mail: t.info.mail, lname: t.info.last_name, name: t.info.name},t.id]
    }
  end
end
