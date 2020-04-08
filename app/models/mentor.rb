# == Schema Information
#
# Table name: mentors
#
#  id               :integer          not null, primary key
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  administrator_id :integer
#  info_id          :integer
#

class Mentor < ActiveRecord::Base
  include Userable

  has_one :user, as: :userable
  has_many :clients, inverse_of: :mentor, dependent: :restrict_with_error
  belongs_to :info, inverse_of: :mentor, autosave: true, dependent: :destroy
  
  validates :administrator_id, presence: true
  validates :info_id, uniqueness: true

  validates_presence_of :info
  validates_associated :info, allow_blank: true
  accepts_nested_attributes_for :info
  accepts_nested_attributes_for :clients

  def username
    "#{info.name} #{info.last_name} | Mentor"
  end

  #Shows info of mentor as a map
  def show
    user_info = self.info.show
    adm = Administrator.find(self.administrator_id)
    info_adm = adm.info
    user_info[:administrator] = info_adm.name + ' ' + info_adm.last_name
    user_info[:organisation] = adm.organisation
    user_info
  end

  def is_my_client? (client_id)
    client = client.find(client_id)
    return false if client.nil?
    client.mentor_id == self.id
  end

  def show_short
    user_info = self.info.show_short
    user_info[:id] = self.id
    adm = Administrator.find(self.administrator_id)
    user_info[:administrator] = adm.show_short
    user_info
  end

  def self.mentors_list (administrator_id)
    Mentor.where(administrator_id: administrator_id).order(:id).map {
        |t| ['%{mail}: %{lname} %{name}'%{mail: t.info.mail, lname: t.info.last_name, name: t.info.name},t.id]
    }
  end

  #List of mentors except current
  def other_mentors
    Mentor.where.not(id: self.id).order(:id).map {
        |t| ['%{mail}: %{lname} %{name}'%{mail: t.info.mail, lname: t.info.last_name, name: t.info.name},t.id]
    }
  end

  def self.all_mentors
    select(
        'mentors.id as mentors_id, t.last_name as last_name, t.name as name,
        a.admin_name as admin_name, a.admin_last_name as admin_last_name,
        a.organisation as organisation, administrator_id'
    ).joins('JOIN infos as t on mentors.info_id = t.id').
    joins("JOIN (#{Administrator.select(
            'administrators.id, infos.name as admin_name,
            infos.last_name as admin_last_name, administrators.organisation'
        ).joins('JOIN infos on administrators.info_id = infos.id').to_sql}) as a on a.id = mentors.administrator_id"
    )
  end

  def self.mentors_of_administrator(admin_id)
    where(administrator_id: admin_id)
  end

  ransack_alias :full_name, :info_last_name_or_info_name
end
