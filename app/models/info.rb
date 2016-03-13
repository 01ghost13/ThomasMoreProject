class Info < ActiveRecord::Base
  has_one :administrator#, inverse_of: :info
  has_one :tutor
  has_secure_password
  validates :name, presence: true, length: { within: 3..20 }
  validates :last_name, presence: true, length: { within: 3..30 }
  #validates :password_digest, presence: true
  validates :mail, presence: true, uniqueness: true, format: { with: /\S+?@.+?\.\S+/i}
  validates :is_mail_confirmed, exclusion: { in: [nil] }
  validates :password, confirmation: true, length: {minimum: 4}
  validates :password, presence: true, on: :create
end
