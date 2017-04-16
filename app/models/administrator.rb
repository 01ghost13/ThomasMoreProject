class Administrator < ActiveRecord::Base
  before_validation :setup_fields, on: :create
  
  has_many :tutors, dependent: :restrict_with_error
  belongs_to :info, inverse_of: :administrator, autosave: true, dependent: :destroy
  
  validates :organisation, presence: true, length: { in: 5..30}
  validates :info_id, uniqueness: true
  validates :is_super, uniqueness: true, if: 'is_super == true'
  validates :is_super, exclusion: { in: [nil] }
  validates :organisation_address, presence: true, uniqueness: true, length: { in: 5..100}

  validates_presence_of :info
  validates_associated :info, allow_blank: true

  accepts_nested_attributes_for :info
  accepts_nested_attributes_for :tutors

  def self.admins_list
    admins = Administrator.where(is_super: false).order(:organisation).map { 
      |t| ['%{org}: %{lname} %{name}'%{org: t.organisation, lname: t.info.last_name, name: t.info.name},t.id]
      }
  end
  
  def setup_fields
    self.is_super = false
    true
  end
  
  def show
    user_info = self.info.show
    user_info[:organisation] = self.organisation
    user_info[:organisation_address] = self.organisation_address
    user_info
  end
  
  def show_short
    user_info = self.info.show_short
    user_info[:organisation] = self.organisation
    user_info[:organisation_address] = self.organisation_address
    user_info[:id] = self.id
    user_info
  end

  def other_administrators
    administrators = Administrator.where.not(['id = ? or is_super = ?',self.id, true]).order(:organisation).map {
        |t| ['%{org}: %{lname} %{name}'%{org: t.organisation, lname: t.info.last_name, name: t.info.name},t.id]
    }
  end
end
