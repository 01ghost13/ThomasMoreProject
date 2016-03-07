class Info < ActiveRecord::Base
  has_one :administrator
  has_one :tutor
  validates :name, presence: true, length: { within: 3..20 }
  validates :last_name, presence: true, length: { within: 3..30 }
  validates :phone, presence: true
  validates :mail, presence: true, uniqueness: true, format: { with: /\S+?@.+?\.\S+/i}
  validates :is_mail_confirmed, presence: true
  has_secure_password
end
