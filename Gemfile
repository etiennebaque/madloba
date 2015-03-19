source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'bundler'
gem 'rails', '4.1.6'

# Use Postgresql as the database for Active Record
gem 'pg'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.2'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Used for API calls
gem 'httparty', '~> 0.13.1'

# Used for authentication
gem 'devise'

# Used for authorization
gem 'pundit'

# Exception notification
gem 'exception_notification', github: 'smartinez87/exception_notification', branch: 'master'

# Gems for image upload
# For AWS cloud storage
gem 'fog'
# File upload solution
gem 'carrierwave'
# Photo resizing
gem 'mini_magick'
# Delayed job
gem 'delayed_job_active_record'
# Processes/Uploads iamge in the background
gem 'carrierwave_backgrounder'

group :development, :test do

  # Mailcatcher
  gem 'mailcatcher'

  # Capistrano
  gem 'capistrano', '~> 3.1.0'
  gem 'capistrano-bundler', '~> 1.1.2'
  gem 'capistrano-rails', '~> 1.1.1'
  gem 'capistrano-rbenv', github: 'capistrano/rbenv'

  # RSpec
  gem 'rspec-rails', '~> 3.0.0'
  gem 'shoulda-matchers', require: false
  gem 'factory_girl_rails'
end

group :test do
  gem 'faker'
  gem 'capybara'
  gem 'guard-rspec'
  gem 'launchy'
  gem 'database_cleaner'
end

# For Heroku deployments
gem 'rails_12factor', group: :production
gem 'unicorn'

# To manage secrets.yml content, on Heroku
# gem 'heroku_secrets', github: 'alexpeattie/heroku_secrets'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use debugger
# gem 'debugger', group: [:development, :test]
