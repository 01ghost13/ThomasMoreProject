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
  belongs_to :employee,
             optional: true,
             class_name: 'Employee'

  has_many :clients,
           dependent: :restrict_with_error,
           inverse_of: :employee
  has_many :employees,
           dependent: :restrict_with_error,
           foreign_key: 'employee_id',
           class_name: 'Employee'

  has_one :user, as: :userable

  accepts_nested_attributes_for :employees
  accepts_nested_attributes_for :clients

  validates_presence_of :name,
                        :last_name

  validates :name, presence: true, length: { within: 3..20 }
  validates :last_name, presence: true, length: { within: 3..30 }
  validates :phone,
            length: {minimum: 6},
            format: {with: /[-0-9)(+]/, message: 'only numbers, plus, minus signs, brackets'},
            unless: ->{ phone.blank? }

  def show
    user_info = {}
    user_info[:last_name] = self.last_name
    user_info[:name] = self.name
    org_name =
      if employee.present?
        employee.organisation
      else
        organisation
      end
    user_info[:organisation] = org_name
    org_address =
        if employee.present?
          employee.organisation_address
        else
          organisation_address
        end
    user_info[:organisation_address] = org_address
    user_info[:phone] = self.phone
    user_info
  end

  def show_nested
    {
      employees: {
        **show
      }
    }
  end

  def full_name
    f = "#{name} #{last_name}"
    if organisation.present?
      f.concat(", '#{organisation}'")
    end

    f
  end
end
