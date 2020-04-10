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
end
