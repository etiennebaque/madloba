FROM ruby:2.2.5-slim

MAINTAINER Etienne Baqué <contact@madloba.org>

# - postgresql-client-9.4: In case you want to talk directly to postgres
RUN apt-get update -qq && apt-get install -y build-essential nodejs libpq-dev postgresql-client-9.4 --fix-missing --no-install-recommends
RUN gem install bundler

ENV MADLOBA_ROOT /var/www/madloba
RUN mkdir -p $MADLOBA_ROOT
WORKDIR $MADLOBA_ROOT

ADD Gemfile $MADLOBA_ROOT/Gemfile
ADD Gemfile.lock $MADLOBA_ROOT/Gemfile.lock
RUN bundle install

# Set Rails to run in production
ENV RAILS_ENV production
ENV RACK_ENV production

ADD . $MADLOBA_ROOT

# Provide dummy data to Rails so it can pre-compile assets.
#RUN bundle exec rake RAILS_ENV=production DATABASE_URL=postgresql://user:pass@127.0.0.1/dbname SECRET_TOKEN=pickasecuretoken assets:precompile
RUN bundle exec rake assets:precompile

# Expose a volume so that nginx will be able to read in assets in production.
VOLUME ["$MADLOBA_ROOT/public"]

EXPOSE 3000

# RUN bundle exec rails server -b 0.0.0.0
CMD [startup.sh]

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
