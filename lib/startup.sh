#!/bin/bash


bundle exec rake db:migrate RAILS_ENV=APP_ENV
bundle exec rake db:seed_fu RAILS_ENV=APP_ENV


if $APP_ENV == 'production'
  sudo service nginx restart
else
  bundle exec rails server -b 0.0.0.0
fi