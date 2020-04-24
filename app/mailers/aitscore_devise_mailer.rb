# Taken from https://github.com/heartcombo/devise/wiki/How-To:-Use-custom-mailer
class AitscoreDeviseMailer < Devise::Mailer
  include SendGrid
  include Devise::Controllers::UrlHelpers

  helper :application
  default template_path: 'devise/mailer'
  default from: 'no-reply@aitscore.com'

  def confirmation_instructions(record, token, opts={})
    return if confirm_client(record)
    super
  end

  def reset_password_instructions(record, token, opts={})
    return if confirm_client(record)
    super
  end

  def unlock_instructions(record, token, opts={})
    return if confirm_client(record)
    super
  end

  def email_changed(record, opts={})
    return if confirm_client(record)
    super
  end

  def password_change(record, opts={})
    return if confirm_client(record)
    super
  end

  private

    def confirm_client(record)
      return false unless record.client?
      record.confirm
    end
end
