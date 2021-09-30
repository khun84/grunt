require_relative 'init'
require 'sidekiq'
require 'sidekiq/web'

map '/' do
  run Main
end

map '/sidekiq' do
  run Sidekiq::Web
end

################################
#
# You could do more maps like:
#
# require_relative 'api_main'
#
# map '/api' do
#   run ApiMain
# end

