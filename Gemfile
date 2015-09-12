source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'bundler'
gem 'rails', '4.2.4'

# Use Postgresql as the database for Active Record
gem 'pg'

# Use SCSS for stylesheets
# gem 'sass-rails', '~> 4.0.5' # scss files not used for now.

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
# gem 'coffee-rails', '~> 4.0.1' # coffee js files not used for now.

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.5.3'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Used for API calls
gem 'httparty', '~> 0.13.1'

# Gem used for authentication
gem 'devise'

# Gem used for authorization
gem 'pundit'

# Exception notification
gem 'exception_notification', '~> 4.1.1'

# Gems for image upload
# File upload solution
gem 'carrierwave'
# Photo resizing
gem 'mini_magick'
# For AWS cloud storage
gem 'fog'
# Delayed job
gem 'delayed_job_active_record'
# Processes/Uploads image in the background
gem 'carrierwave_backgrounder'
# Daemons gem to activate Delayed job via Capistrano
gem 'daemons'

# Memcache client
gem 'dalli'
gem 'memcachier'

# For neested forms
gem 'cocoon'

# Text in Javascript file
gem 'gon'

# Simple captcha - used when anonymous users create new ads, or reply to existing ones.
gem 'simple_captcha2', require: 'simple_captcha'

group :development, :test do

  # Mailcatcher
  gem 'mailcatcher'

  # Capistrano
  gem 'capistrano3-delayed-job', '~> 1.0'
  gem 'capistrano', '~> 3.4.0'
  gem 'capistrano-bundler', '~> 1.1.2'
  gem 'capistrano-rails', '~> 1.1.1'
  gem 'capistrano-rbenv', '~> 2.0.3'

  # RSpec
  gem 'rspec-rails', '~> 3.3.3'
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

# Gems related to translation
gem 'i18n-tasks', '~> 0.8.3'
gem 'rails-i18n', '~> 4.0.0'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use debugger
# gem 'debugger', group: [:development, :test]
