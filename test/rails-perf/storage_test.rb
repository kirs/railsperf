require 'test_helper'
require 'rails-perf/storage'
require 'pry'

class TestStorage < Minitest::Test
  def setup
    @storage = RailsPerf::Storage.new
    @storage.builds.drop
  end

  def test_find_build
    inserted_id = @storage.builds.insert(build_sample)

    found = @storage.find_build(inserted_id.to_s)
    assert_equal RailsPerf::Build, found.class
    assert_equal found.target, build_sample[:target]

    assert_equal found, @storage.find_build(inserted_id)
  end

  def test_find_build_or_raise
    assert_raises RailsPerf::Storage::BuildNotFoundError do
      @storage.find_build!(1)
    end
  end

  def test_insert_build
    assert_equal 0, @storage.builds.count

    build = RailsPerf::Build.new.tap do |b|
      b.title = 'something'
      b.target = [
        ['rails', '~> 3.2.21'],
        ['sqlite3']
      ]
    end

    @storage.insert_build(build)

    assert_equal 1, @storage.builds.count

    assert build.id.present?
    assert_equal 'something', build.title
  end

  private

  def build_sample
    {
      benchmark_code: '1+1',
      target: [
        ['rails', '~> 3.2.21'],
        ['sqlite3']
      ],
      dir_id: rand(10)
    }
  end
end
