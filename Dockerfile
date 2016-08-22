FROM ruby:2.2.4
RUN apt-get update -qq && apt-get install -y build-essential nodejs npm nodejs-legacy postgresql-client vim

ENV RAILS_ROOT /var/www/madloba
RUN mkdir -p $RAILS_ROOT/tmp/pids

WORKDIR $RAILS_ROOT

COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN gem install bundler
RUN bundle install

COPY . .

RUN RAILS_ENV=production bundle exec rake assets:precompile --trace
CMD ["rails","server","-b","0.0.0.0"]