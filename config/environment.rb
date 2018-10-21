# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

# Configure mail
ActionMailer::Base.raise_delivery_errors = true
if Rails.env.development?
  ActionMailer::Base.smtp_settings = {
      :address        => 'smtp.gmail.com',
      :domain         => 'mail.google.com',
      :port           => 587,
      :user_name      => 'derpyaitscore@gmail.com',
      :password       => 'animespirit',
      :authentication => :plain,
      :enable_starttls_auto => true
  }
else
  ActionMailer::Base.smtp_settings = {
      :address        => 'smtp.gmail.com',
      :domain         => 'mail.google.com',
      :port           => 587,
      :user_name      => ENV['MAIL_USER'],
      :password       => ENV['MAIL_PASSWORD'],
      :authentication => :plain,
      :enable_starttls_auto => true
  }
end
