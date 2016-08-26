FROM ruby:2.2.4
RUN apt-get update -qq && apt-get install -y build-essential nodejs npm nodejs-legacy postgresql-client vim
RUN gem install bundler

ENV RAILS_ROOT /var/www/madloba

WORKDIR $RAILS_ROOT

ADD Gemfile $RAILS_ROOT/Gemfile
ADD Gemfile.lock $RAILS_ROOT/Gemfile.lock
RUN bundle install

ADD . $RAILS_ROOT

RUN RAILS_ENV=production bundle exec rake assets:precompile --trace