# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

# Configure mail
ActionMailer::Base.raise_delivery_errors = true
unless Rails.env.development?
  ActionMailer::Base.smtp_settings = {
      address: "smtp.sendgrid.net",
      port: 25,
      domain: "aitscore.com",
      authentication: :plain,
      user_name: ENV['SENDGRID_USERNAME'],
      password: ENV['SENDGRID_PASSWORD']
  }
end
