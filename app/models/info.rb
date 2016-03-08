class Info < ActiveRecord::Base
  has_one :administrator
  has_one :tutor
  validates :name, presence: true, length: { within: 3..20 }
  validates :last_name, presence: true, length: { within: 3..30 }
  validates :password_digest, presence: true
  validates :mail, presence: true, uniqueness: true, format: { with: /\S+?@.+?\.\S+/i}
  has_secure_password
end
