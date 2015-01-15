require './server.rb'

require 'sidekiq/web'
# run Sinatra::Application
run Rack::URLMap.new('/' => Sinatra::Application, '/sidekiq' => Sidekiq::Web)
