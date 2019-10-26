# == Schema Information
#
# Table name: tutors
#
#  id               :integer          not null, primary key
#  info_id          :integer
#  administrator_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

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
    Tutor.where(administrator_id: administrator_id).order(:id).map {
        |t| ['%{mail}: %{lname} %{name}'%{mail: t.info.mail, lname: t.info.last_name, name: t.info.name},t.id]
    }
  end

  #List of tutors except current
  def other_tutors
    Tutor.where.not(id: self.id).order(:id).map {
        |t| ['%{mail}: %{lname} %{name}'%{mail: t.info.mail, lname: t.info.last_name, name: t.info.name},t.id]
    }
  end

  def self.all_tutors
    select(
        'tutors.id as tutors_id, t.last_name as last_name, t.name as name,
        a.admin_name as admin_name, a.admin_last_name as admin_last_name,
        a.organisation as organisation, administrator_id'
    ).joins('JOIN infos as t on tutors.info_id = t.id').
    joins("JOIN (#{Administrator.select(
            'administrators.id, infos.name as admin_name,
            infos.last_name as admin_last_name, administrators.organisation'
        ).joins('JOIN infos on administrators.info_id = infos.id').to_sql}) as a on a.id = tutors.administrator_id"
    )
  end

  def self.tutors_of_administrator(admin_id)
    where(administrator_id: admin_id)
  end

  ransack_alias :full_name, :info_last_name_or_info_name
end
