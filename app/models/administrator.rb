class Administrator < ActiveRecord::Base
  before_validation :setup_fields, on: :create
  has_many :tutors
  belongs_to :info, inverse_of: :administrator
  validates :organisation, presence: true, length: { in: 5..20}
  validates :info_id, presence: true, uniqueness: true
  validates :is_super, uniqueness: true, if: "is_super == true"
  validates :is_super, exclusion: { in: [nil] }
  validates :organisation_address, presence: true, uniqueness: true, length: { in: 5..20}
  
  def self.admins_list
    admins = Administrator.where(is_super: false).order(:organisation).map { 
      |t| ["%{org}: %{lname} %{name}"%{org: t.organisation, lname: t.info.last_name, name: t.info.name},t.id]
      }
  end
  
  def setup_fields
    self.is_super = false
    return true
  end
  
  def show
    user_info = self.info.show
    user_info[:organisation] = self.organisation
    user_info[:organisation_address] = self.organisation_address
    return user_info
  end
end
