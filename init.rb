require 'rubygems'
require 'bundler'

ENV['RACK_ENV'] ||= 'development'
Bundler.setup(:default, ENV['RACK_ENV'])
# load gemfile
require 'nokogiri'
require 'sidekiq'
require 'sinatra'
require 'config'
require 'rest-client'
require 'chronic'
require 'chronic_duration'
require 'active_support/all'

# register config file
Sinatra::Application.class_eval do
  set :root, File.dirname(__FILE__)
  register Config
end

APP_ROOT = File.absolute_path(File.dirname(__FILE__))
LIB_DIR = File.join(APP_ROOT, 'lib')
LOG_DIR = File.join(APP_ROOT, 'log')
TMP_DIR = File.join(APP_ROOT, 'tmp')
CFG_DIR = File.join(APP_ROOT, 'config')

INITIALIZERS_DIR = File.join(APP_ROOT, 'initializers')

Dir.glob(File.join(INITIALIZERS_DIR, '**', '*.rb')).each do |f|
  require f
end

Dir.glob(File.join(LIB_DIR, '**', '*.rb')).each do |f|
  require f
end

# This must be named "config" and be under the APP_ROOT, otherwise
# sinatra/activerecord can't find it.

$:.unshift LIB_DIR

