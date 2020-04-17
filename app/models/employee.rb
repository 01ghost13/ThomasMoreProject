# == Schema Information
#
# Table name: employees
#
#  id                   :bigint           not null, primary key
#  last_name            :string
#  name                 :string
#  organisation         :string
#  organisation_address :string
#  phone                :string
#  employee_id          :bigint
#

class Employee < ActiveRecord::Base
  belongs_to :employee, optional: true

  has_many :clients
  has_many :employees, dependent: :restrict_with_error

  has_one :user, as: :userable, inverse_of: :user

  accepts_nested_attributes_for :employees

  def show
    user_info = {}
    user_info[:last_name] = self.last_name
    user_info[:name] = self.name
    user_info[:organisation] = self.organisation
    user_info[:organisation_address] = self.organisation_address
    user_info[:phone] = self.phone
    user_info
  end
end
