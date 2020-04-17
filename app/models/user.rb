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

  belongs_to :administrator, foreign_key: 'userable_id', optional: true
  belongs_to :mentor, foreign_key: 'userable_id', optional: true
  belongs_to :client, foreign_key: 'userable_id', optional: true, dependent: :destroy

  belongs_to :employee, foreign_key: 'userable_id', optional: true, dependent: :destroy

  belongs_to :userable, polymorphic: true, optional: true

  accepts_nested_attributes_for :administrator
  accepts_nested_attributes_for :mentor
  accepts_nested_attributes_for :client
  accepts_nested_attributes_for :employee

  def role_model
    return client if client?

    employee
  end

  def show
    user_info = role_model.show
    user_info[:email] = self.email
    user_info
  end

  def local_admin?
    role == 'local_admin' || super_admin?
  end

  ransack_alias :full_name, :employee_last_name_or_employee_name
end
