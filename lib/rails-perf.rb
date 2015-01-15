require 'rails-perf/storage'
require 'rollbar'

module RailsPerf
  def self.storage
    @storage ||= Storage.new
  end

  Rollbar.configure do |config|
    config.access_token = 'aa868d34e3374a68a614717b70550e52'
    config.disable_monkey_patch = true

    config.enabled = ENV['RACK_ENV'] == 'production'
  end
end
