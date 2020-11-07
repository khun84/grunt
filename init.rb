ENV['BUNDLE_GEMFILE'] ||= File.expand_path('./Gemfile', __dir__)
ENV['RACK_ENV'] ||= 'development'
ENV['ENV'] ||= ENV['RACK_ENV']
require 'rubygems'
require 'bundler/setup'

Bundler.require(:default, ENV['RACK_ENV'])

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

require_relative './main'

# This must be named "config" and be under the APP_ROOT, otherwise
# sinatra/activerecord can't find it.

$:.unshift LIB_DIR

