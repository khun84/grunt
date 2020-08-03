FROM ruby:2.4.1-alpine

ENV BUNDLER_VERSION=2.0.1

RUN apk add --no-cache --quiet --virtual .build-deps build-base curl nano vim git

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN gem install bundler --no-document --version $BUNDLER_VERSION && \
    bundle install --jobs 20 --retry 5 --clean --quiet

COPY . .

CMD ["bundle", "exec", "rake", "console"]
