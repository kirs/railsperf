require 'bundler/setup'

$:.push File.expand_path("../lib", __FILE__)
require 'rails-perf/sidekiq'

require 'sidekiq/api'
Sidekiq::RetrySet.new.clear
Sidekiq::Queue.new.clear
