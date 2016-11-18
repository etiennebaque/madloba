FROM ruby:2.2.4
RUN apt-get update -qq && apt-get install -y build-essential nodejs npm nodejs-legacy postgresql-client vim
RUN gem install bundler

ENV RAILS_ROOT /var/www/madloba

WORKDIR $RAILS_ROOT

ADD Gemfile $RAILS_ROOT/Gemfile
ADD Gemfile.lock $RAILS_ROOT/Gemfile.lock
RUN bundle install

ADD . $RAILS_ROOT
EXPOSE 3000

RUN bundle exec rails server -b 0.0.0.0
# CMD [startup.sh]

#In startup.sh
#
#if $APP_ENV = 'production'
#  - use nginx
#else
#  - use thin
#
#Set up the environment variable in docker-compose (in environment node)
#Run the export command (to set the values for env vars )before running docker-compose.
#
#db:seed_fu in startup.sh
#
