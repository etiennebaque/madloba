FROM etiennebaque/madloba-base:latest
MAINTAINER Etienne Baqué <contact@madloba.org>

#ARG password=defaultPassword
#USER postgres
#RUN /etc/init.d/postgresql start && psql --command "CREATE USER docker WITH SUPERUSER PASSWORD '$password';" && createdb -O docker docker

ENV MADLOBA_ROOT /var/www/madloba
WORKDIR $MADLOBA_ROOT

ADD Gemfile $MADLOBA_ROOT/Gemfile
ADD Gemfile.lock $MADLOBA_ROOT/Gemfile.lock
RUN bundle install --without development test

# Set Rails to run in production
ENV RAILS_ENV production
ENV RACK_ENV production

ADD . $MADLOBA_ROOT

# Provide dummy data to Rails so it can pre-compile assets.
#RUN bundle exec rake RAILS_ENV=production DATABASE_URL=postgresql://user:pass@127.0.0.1/dbname SECRET_TOKEN=pickasecuretoken assets:precompile
RUN RAILS_ENV=production bundle exec rake assets:precompile --trace

# Expose a volume so that nginx will be able to read in assets in production.
VOLUME ["$MADLOBA_ROOT/public"]

EXPOSE 3000

# RUN bundle exec rails server -b 0.0.0.0

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
