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

  belongs_to :userable, polymorphic: true
  belongs_to :administrator, foreign_key: 'userable_id'
  belongs_to :mentor, foreign_key: 'userable_id'
  belongs_to :client, foreign_key: 'userable_id'

  def role_model
    return administrator if local_admin? || super_admin?
    return client if client?
    mentor if mentor?
  end

  def local_admin?
    role == 'local_admin' || super_admin?
  end
end
