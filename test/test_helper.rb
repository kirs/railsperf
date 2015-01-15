$:.push File.expand_path("../../lib", __FILE__)

ENV["TEST"] ||= 'true'

require 'minitest/autorun'

require 'sidekiq'
require 'sidekiq/testing'
require 'webmock/minitest'
require 'pry'

# Add support to load paths
$:.unshift File.expand_path('../support', __FILE__)
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

class Minitest::Test
  def fixture_path(fixture)
    current = Pathname.new(File.dirname(__FILE__))
    current.join("fixtures", fixture)
  end
end
