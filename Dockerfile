FROM ruby:2.2

ADD Gemfile /app/
WORKDIR /app

RUN bundle install
# not sure I understand, but the picobrew-api gem coming
# from Github instead of RubyGems seems to require
# two `bundle install` calls to work.
RUN bundle install

ADD . /app

ENV PATH .:$PATH
ENV PORT 3000
EXPOSE 3000
CMD puma --environment production config/config.ru
