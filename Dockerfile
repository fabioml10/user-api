FROM ruby:2.5.1

RUN apt-get update -qq && apt-get install -y build-essential postgresql-client

# for postgres
RUN apt-get install -y libpq-dev

# for nokogiri
RUN apt-get install -y libxml2-dev libxslt1-dev

# for a JS runtime
RUN apt-get install -y nodejs

ENV APP_HOME /user-api
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD . $APP_HOME

RUN bundle install
ENTRYPOINT ["sh", "./docker-entrypoint.sh"]

CMD ["rails", "server", "--binding", "0.0.0.0"]
