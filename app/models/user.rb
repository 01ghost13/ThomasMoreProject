# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  date_off               :date
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  is_active              :boolean          default(TRUE), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  role                   :integer          not null
#  userable_type          :string           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  language_id            :bigint           default(1), not null
#  userable_id            :bigint           not null
#

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable,
         :rememberable,
         :validatable,
         :confirmable

  enum role: { client: 0, local_admin: 1, mentor: 2, super_admin: 3 }

  scope :all_local_admins, ->{ where(role: :local_admin) }
  scope :all_clients, ->{ where(role: :client) }
  scope :all_mentors, ->{ where(role: :mentor) }
  scope :all_super_admins, ->{ where(role: :super_admin) }
  scope :other_local_admins, ->(id){ all_local_admins.where.not(id: id) }
  scope :other_mentors, ->(id){ all_mentors.where.not(id: id) }
  # todo not the best place for scope
  scope :mentors_of_administrator, ->(id){ where('employees.employee_id = :id', id: id) }

  belongs_to :administrator, foreign_key: 'userable_id', optional: true
  belongs_to :mentor, foreign_key: 'userable_id', optional: true
  belongs_to :client, foreign_key: 'userable_id', optional: true

  belongs_to :employee, foreign_key: 'userable_id', optional: true

  belongs_to :userable, polymorphic: true, optional: true, dependent: :destroy

  belongs_to :language

  has_many :test_availabilities, dependent: :destroy

  accepts_nested_attributes_for :administrator
  accepts_nested_attributes_for :mentor
  accepts_nested_attributes_for :client
  accepts_nested_attributes_for :employee

  class << self
    # TODO FIX n+1 query
    def admins_list
      all_local_admins
        .joins(:employee)
        .order('employees.organisation')
        .select { |u| u.employee.employees.count.positive? }
        .map do |t|
          employee = t.employee
          org = '%{org}: %{lname} %{name}' % { org: employee.organisation, lname: employee.last_name, name: employee.name }
          [org, employee.id]
        end
    end

    def mentors_list(employee_id)
      all_mentors
        .joins(:employee)
        .where('employees.employee_id': employee_id)
        .order(:id)
        .map do |t|
          employee = t.employee
          view_s = '%{email}: %{lname} %{name}'%{email: t.email, lname: employee.last_name, name: employee.name}
          [view_s, employee.id]
        end
    end

    def clients_of_admin(admin_id)
      all_clients_ransack.where('admin_id = ?', admin_id)
    end

    def clients_of_mentor(mentor_id)
      all_clients_ransack.where('clients.employee_id = ?', mentor_id)
    end

    def all_clients_ransack
      mentors = User
        .all_mentors
        .select(
          'employees.name as mentor_name, employees.last_name as mentor_last_name,
           employees.id as m_id, employees.employee_id as admin_id, users.id as mentor_user_id'
        )
        .joins(:employee)
        .to_sql

      administrators = User
        .all_local_admins
        .select(
          'employees.name as admin_name, employees.last_name as admin_last_name,
          employees.id as a_id, employees.organisation, users.id as admin_user_id'
        )
        .joins(:employee)
        .to_sql

      all_clients
        .select(
          'users.id as id, clients.code_name as code_name, t.mentor_name as mentor_name, t.m_id as mentor_id,
          t.mentor_last_name as mentor_last_name, a.admin_name as admin_name, a.admin_last_name as admin_last_name,
          a.organisation as organisation, t.admin_id as administrator_id, clients.employee_id, users.is_active,
          admin_user_id, mentor_user_id'
        )
        .joins(:client)
        .joins("JOIN (#{mentors}) as t on clients.employee_id = t.m_id")
        .joins("JOIN (#{administrators}) as a on t.admin_id = a.a_id")
    end
  end

  def role_model
    return client if client?

    employee
  end

  def show
    user_info = role_model.show
    user_info[:email] = self.email
    user_info
  end

  def show_nested
    {
      users: {
        email: email
      },
      **role_model.show_nested
    }
  end

  def local_admin?
    role == 'local_admin' || super_admin?
  end

  # Hides client for all users except SA
  # TODO MOVE TO MODULE
  def hide
    self.date_off =
      if is_active
        Date.current
      end
    self.is_active = !self.is_active

    save
  end

  def policy_class
    if super_admin? || local_admin?
      AdministratorPolicy
    elsif mentor?
      MentorPolicy
    elsif client?
      ClientPolicy
    end
  end

  ransack_alias :full_name, :employee_last_name_or_employee_name
  ransack_alias :code_name, :client_code_name
end
