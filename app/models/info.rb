class Info < ActiveRecord::Base
  before_validation :setup_fields, on: :create
  before_create :generate_mail_token
  has_one :administrator, inverse_of: :info
  has_one :tutor, inverse_of: :info
  
  has_secure_password
  validates :name, presence: true, length: { within: 3..20 }
  validates :last_name, presence: true, length: { within: 3..30 }
  validates :mail, presence: true, uniqueness: true, format: { with: /\S+?@.+?\.\S+/i}
  validates :is_mail_confirmed, exclusion: { in: [nil] }
  validates :password, presence: true, allow_nil: true, length: {minimum: 4}
  validates :phone, length: {minimum: 6}, format: {with: /[-0-9)(+]/, message: 'only numbers, plus, minus signs, brackets'}, unless: 'phone.blank?'

  def setup_fields
    self.is_mail_confirmed = false
    true
  end

  def generate_mail_token
    if self.confirm_token.blank?
      self.confirm_token = SecureRandom.urlsafe_base64.to_s
    end
  end
  
  #Shows info
  def show
    user_info = show_short
    user_info[:email] = self.mail
    user_info
  end

  def show_short
    user_info = {name: self.name}
    user_info[:last_name] = self.last_name
    user_info
  end

  def email_activate
    self.is_mail_confirmed = true
    self.confirm_token = nil
    save(validate: false)
  end

  def email_reset
    self.reset_token = SecureRandom.urlsafe_base64.to_s
    save(validate: false)
  end

  def reset_password(params)
    permitted = params.permit(:password, :password_confirmation)
    if update(permitted)
      self.reset_token = nil
      save(validate: false)
      true
    else
      false
    end
  end

  private :generate_mail_token, :setup_fields
end
