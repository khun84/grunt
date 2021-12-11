source 'https://rubygems.org'
ruby File.read('.ruby-version')

gem 'activerecord'
gem 'sinatra'
gem "sinatra-activerecord"
gem 'sinatra-contrib'
# gem 'sinatra-activerecord'
# If you want mysql, replace the pg gem with a mysql gem, and change
# the "adapter" in config/database.yml.
# gem 'pg'
gem 'rake'
gem 'rest-client'
gem 'sidekiq', '~> 5.0'
gem 'config', require: 'config'
gem 'activesupport', require: 'active_support/all'
gem 'nokogiri'
gem 'elasticsearch-model'
gem 'sqlite3'
gem 'chronic'
gem 'chronic_duration'
gem 'logstash-logger'
gem 'sinatra-cross_origin'
gem 'fog-aws'
gem 'aws-sdk-sqs'
gem 'aws-sdk-s3'
gem 'shoryuken'
gem 'terminal-table'

group :development, :test do
  gem 'byebug'
  gem 'thin'
end

group :test do
  gem 'rack-test'
  gem 'rspec'
  gem 'rspec-json_expectations'
end

group :deployment do
  # gem 'capistrano', '~> 3.3.0'
  # gem 'capistrano-bundler', '~> 1.1.2'
  # gem 'capistrano-rvm'
end

