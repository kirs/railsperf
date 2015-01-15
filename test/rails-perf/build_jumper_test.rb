require 'test_helper'

require 'rails-perf'
require 'rails-perf/build_jumper'

class TestBuildJumper < Minitest::Test

  def setup
    DbCleaner.run
  end

  def test_existing_build
    build = prepare_build

    jumper = RailsPerf::BuildJumper.new(build.tag)

    assert_equal 1, RailsPerf.storage.builds.count
    jumper.find_or_create
    assert_equal 1, RailsPerf.storage.builds.count

    assert_equal build.id, jumper.build_id
  end

  def test_new_build
    stub_github_api

    jumper = RailsPerf::BuildJumper.new('850159bd2c5e1e108d0256dd05424bbbf7926b59')

    assert_equal 0, RailsPerf.storage.builds.count
    jumper.find_or_create
    assert_equal 1, RailsPerf.storage.builds.count

    assert jumper.build_id.present?

    build = RailsPerf.storage.find_build(jumper.build_id)
  end

  def test_not_existing_build
    stub_not_existing_github_api

    jumper = RailsPerf::BuildJumper.new('850159bd2c5e1e108d0256dd05424bbbf7926b59')

    assert_equal 0, RailsPerf.storage.builds.count
    assert_raises RailsPerf::BuildJumper::InvalidRefError do
      jumper.find_or_create
    end
    assert_equal 0, RailsPerf.storage.builds.count

    assert jumper.build_id.blank?
  end

  private

  def prepare_build
    build = RailsPerf::Build.new
    build.target = [['activerecord', { github: 'rails/rails', tag: '850159bd2c5e1e108d0256dd05424bbbf7926b59'}]]
    build.tag = '850159bd2c5e1e108d0256dd05424bbbf7926b59'
    RailsPerf.storage.insert_build(build)

    build
  end

  def stub_github_api
    stub_request(:get, "https://api.github.com/repos/rails/rails/commits/850159bd2c5e1e108d0256dd05424bbbf7926b59").
      with(:headers => {'Accept'=>'application/vnd.github.v3+json', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'User-Agent'=>'Octokit Ruby Gem 3.5.2'}).
      to_return(:status => 200, :body => commit_body, :headers => {'Content-Type'=>'application/json'})
  end

  def stub_not_existing_github_api
    stub_request(:get, "https://api.github.com/repos/rails/rails/commits/850159bd2c5e1e108d0256dd05424bbbf7926b59").
      with(:headers => {'Accept'=>'application/vnd.github.v3+json', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'User-Agent'=>'Octokit Ruby Gem 3.5.2'}).
      to_return(:status => 404, :body => "", :headers => {})
  end

  def commit_body
    File.open(fixture_path('commit.json')).read
  end
end
