class AitscoreMailer < ApplicationMailer
  default from: 'derpy@aitscore.com'
  def registration_confirmation(user)
    @user = user
    mail(to: "#{user.last_name} #{user.name} <#{user.mail}>", subject: 'Registration Confirmation')
  end
end
