
FROM ruby:2.7.1-slim
LABEL maintainer Travis CI GmbH <support+travis-honeytail-docker-images@travis-ci.com>

# packages required for bundle install, jq and honeytail
RUN ( \
   apt-get update ; \
   apt-get install -y --no-install-recommends git make gcc g++ libpq-dev jq wget \
   && rm -rf /var/lib/apt/lists/* ; \
   wget https://honeycomb.io/download/honeytail/linux/honeytail_1.591_amd64.deb && apt-get install -y ./honeytail_1.591_amd64.deb \
)

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1
RUN bundle config set deployment 'true'

RUN mkdir -p /app
WORKDIR /app

COPY Gemfile      /app
COPY Gemfile.lock /app

RUN gem install bundler
RUN bundler install --verbose --retry=3
RUN gem install --user-install executable-hooks

COPY . /app
