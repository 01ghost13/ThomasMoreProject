# @deprecated
class AitscoreMailer < ApplicationMailer
  default from: 'derpy@aitscore.com'

  def registration_confirmation(user)
    send_mail(user, 'Registration Confirmation')
  end

  def reset_password(user)
    send_mail(user, 'Reset Password')
  end

  private
    def send_mail(user, subject)
      @user = user
      mail(to: "#{user.last_name} #{user.name} <#{user.mail}>", subject: subject)
    end
end
