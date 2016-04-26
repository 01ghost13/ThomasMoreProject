class Info < ActiveRecord::Base
  before_validation :setup_fields, on: :create
  
  has_one :administrator, inverse_of: :info
  has_one :tutor, inverse_of: :info
  
  has_secure_password
  validates :name, presence: true, length: { within: 3..20 }
  validates :last_name, presence: true, length: { within: 3..30 }
  validates :mail, presence: true, uniqueness: true, format: { with: /\S+?@.+?\.\S+/i}
  validates :is_mail_confirmed, exclusion: { in: [nil] }
  validates :password, presence: true, allow_nil: true, length: {minimum: 4}
  
  def setup_fields
    #!While system of confirmation isnt work
    self.is_mail_confirmed = true
    return true
  end
  
  #Shows info
  def show
    user_info = {name: self.name}
    user_info[:last_name] = self.last_name
    user_info[:email] = self.mail
    return user_info
  end
end
