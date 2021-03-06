# == Schema Information
#
# Table name: administrators
#
#  id                   :integer          not null, primary key
#  is_super             :boolean
#  organisation         :string
#  info_id              :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  organisation_address :string
#

# @deprecated
class Administrator < ActiveRecord::Base
  include Userable

  before_validation :setup_fields, on: :create
  
  has_many :mentors, dependent: :restrict_with_error
  has_one :user, as: :userable
  # @deprecated
  belongs_to :info, inverse_of: :administrator, autosave: true, dependent: :destroy, optional: true
  
  validates :organisation, presence: true, length: { in: 5..30}
  validates :info_id, uniqueness: true
  validates :is_super, uniqueness: true, if: ->{ is_super }
  validates :is_super, exclusion: { in: [nil] }
  validates :organisation_address, presence: true, uniqueness: true, length: { in: 5..100}

  # validates_presence_of :info
  # validates_associated :info, allow_blank: true

  accepts_nested_attributes_for :info
  accepts_nested_attributes_for :mentors

  def username
    "#{info.name} #{info.last_name} | Administrator"
  end

  #returns list of admins for viewing
  def self.admins_list
    Administrator.where(is_super: false).order(:organisation).map {
      |t| ['%{org}: %{lname} %{name}'%{org: t.organisation, lname: t.info.last_name, name: t.info.name},t.id]
      }
  end

  #Setups default fields
  def setup_fields
    self.is_super = false
    true
  end

  #Full information about admin
  def show
    user_info = self.info.show
    user_info[:organisation] = self.organisation
    user_info[:organisation_address] = self.organisation_address
    user_info
  end

  #Short information about admin
  def show_short
    user_info = self.info.show_short
    user_info[:organisation] = self.organisation
    user_info[:organisation_address] = self.organisation_address
    user_info[:id] = self.id
    user_info
  end

  #Returns other administrators for viewing in option-html-tag
  def other_administrators
    Administrator.where.not(['id = ? or is_super = ?',self.id, true]).order(:organisation).map {
        |t| ['%{org}: %{lname} %{name}'%{org: t.organisation, lname: t.info.last_name, name: t.info.name},t.id]
    }
  end

  def self.all_administrators
    select(
        'a.name as name, a.last_name as last_name, administrators.id as id,
        organisation, organisation_address'
    ).joins('JOIN infos as a on administrators.info_id = a.id').where(is_super: false)
  end
  ransack_alias :full_name, :info_last_name_or_info_name
end
