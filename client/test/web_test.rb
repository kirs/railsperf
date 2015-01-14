require File.expand_path '../test_helper.rb', __FILE__

class WebTest < Minitest::Test

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    DbCleaner.run
  end

  # def test_build_page
  #   insert_global_builds
  #   build = insert_current_build

  #   get "/builds/#{build.id}"
  #   assert last_response.ok?

  #   doc = Nokogiri::HTML(last_response.body)
  #   # doc.css("")
  #   # assert_equal "Hello, World!", last_response.body
  # end

end
