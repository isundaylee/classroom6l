FROM 'ruby:2.2.4-alpine'

# RUN bundle config --global frozen 1

RUN apk add --update \
  build-base \
  git \
  nodejs \
  tzdata \
  libxml2-dev \
  libxslt-dev \
  postgresql-dev

WORKDIR /usr/src/app

RUN bundle config build.nokogiri -- --use-system-libraries
COPY Gemfile* ./
RUN bundle install

COPY . .

CMD ["bundle", "exec", "rails", "server"]
