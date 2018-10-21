source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

ruby '2.4.4'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.4'

# Use Puma as the app server
gem 'puma', '~> 3.7'

# Postgres
gem 'pg'
gem 'rails_12factor'

# Use SCSS for stylesheets
gem 'sass-rails', '>= 5.0.7'
gem 'bootstrap-sass'

# Use jquery as the JavaScript library
gem 'jquery-rails', '~> 4.3'

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# React
gem 'react-rails', '~> 1.7'

# Manipulate images with minimal use of memory via ImageMagick / GraphicsMagick (https://github.com/minimagick/minimagick)
gem "mini_magick"

# Ruby binding to ImageMagick (https://github.com/rmagick/rmagick)
gem 'rmagick', '~> 2.16.0', require: 'rmagick'

# Embed the V8 JavaScript interpreter into Ruby (http://github.com/cowboyd/therubyracer)
gem 'therubyracer'

# Simple, efficient background processing for Ruby (http://sidekiq.org)
gem 'sidekiq'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# For pagination
gem 'kaminari'

# ReCaptcha
gem 'recaptcha', :require => 'recaptcha/rails'

# Charts
# https://github.com/ankane/chartkick
gem 'chartkick'

# Search engine
# https://github.com/activerecord-hackery/ransack
gem 'ransack', github: 'activerecord-hackery/ransack'

# Working with xls
# https://github.com/straydogstudio/axlsx_rails
gem 'rubyzip', '~> 1.1.7'
gem 'axlsx', '2.1.0.pre'
gem 'axlsx_rails'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

group :production do
# Use Uglifier as compressor for JavaScript assets
  gem 'uglifier', '>= 1.3.0'

  gem 'pg'
  gem 'rails_12factor'
  #gem for adding pictures
  #https://github.com/GoGoCarl/paperclip-cloudinary
  gem 'paperclip-cloudinary'
end

group :test do
  # RSpec for Rails (https://github.com/rspec/rspec-rails)
  gem 'rspec-rails', '~> 3.5'
end

group :development, :test do
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  # For seeds
  gem 'faker'
end

group :development do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]

  # Automatic Ruby code style checking tool. (https://github.com/rubocop-hq/rubocop)
  gem 'rubocop', require: false # Статический анализатор

  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # Better error page for Rails and other Rack apps (https://github.com/charliesome/better_errors)
  gem 'better_errors'
end
