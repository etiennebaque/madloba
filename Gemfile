source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'bundler'
gem 'rails', '4.2.7.1'

# Use Postgresql as the database for Active Record
gem 'pg'

# Use Bootstrap and SCSS for stylesheets
gem 'bootstrap-sass', '~> 3.3.6'
gem 'sass-rails', '>= 3.2'
gem 'bootstrap-growl-rails'

gem 'sprockets-rails', '2.3.3'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.1'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
#gem 'turbolinks'

# jQuery plugin for drop-in fix binded events problem caused by Turbolinks
#gem 'jquery-turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
#gem 'jbuilder', '~> 2.3.1'

gem 'haml'
gem 'seed-fu', '~> 2.3'
gem 'simple_form'

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

# Gem to enable use of websockets.
gem 'faye-websocket'

# Get inputs from madloba:install task
gem 'highline'

gem 'font-awesome-sass'
gem 'will_paginate', '~> 3.1.0'

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

  gem 'awesome_print'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-commands-cucumber'

  gem 'haml-rails'
  gem 'pry-byebug'
end

group :test do
  gem 'faker'
  gem 'capybara'
  gem 'guard-rspec'
  gem 'launchy'

  gem 'cucumber-rails', :require => false
  gem 'database_cleaner'
  gem 'selenium-webdriver'
  gem 'capybara-screenshot'
  gem 'capybara-webkit'
end

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# For Heroku deployments... (not for now)
# gem 'unicorn'

gem 'puma'
gem 'rails_12factor', group: :production

# Gems related to translation
gem 'i18n-tasks', '~> 0.8.3'
gem 'rails-i18n', '~> 4.0.0'