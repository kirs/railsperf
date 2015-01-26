require File.expand_path '../test_helper.rb', __FILE__

class WebTest < Minitest::Test

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    DbCleaner.run
  end

  def test_push_payload
    fixtures = Pathname.new(File.dirname(__FILE__)).join("fixtures")
    raw_payload = File.open(fixtures.join("payload.json")).read

    post "/webhook", raw_payload, "CONTENT_TYPE" => 'application/json'

    assert last_response.ok?
  end

  # def test_build_page
  #   insert_global_builds
  #   build = insert_current_build

  #   get "/builds/#{build.id}"
  #   assert last_response.ok?

  #   doc = Nokogiri::HTML(last_response.body)
  #   js_data = doc.css(".js-benchmarks-data")
  #   raise js_data.inspect
  #   # assert_equal "Hello, World!", last_response.body
  # end

end
