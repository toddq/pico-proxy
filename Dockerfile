FROM ruby:2.2

ADD Gemfile /app/
WORKDIR /app

RUN bundle install

ADD . /app

ENV PATH .:$PATH
ENV PORT 3000
EXPOSE 3000
CMD puma --environment production config/config.ru
