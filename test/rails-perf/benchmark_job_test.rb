require 'test_helper'
require 'rails-perf/jobs'
require 'rails-perf/gemfile_builder'
require 'rails-perf/build'
require 'pathname'

class TestBenchmarkJob < Minitest::Test
  def setup
    DbCleaner.run
  end

  def test_raises_not_found
    assert_equal 0, RailsPerf.storage.reports.count

    assert_raises RailsPerf::Storage::BuildNotFoundError do
      RailsPerf::Jobs::BenchmarkJob.new.perform(1, "")
    end

    assert_equal 0, RailsPerf.storage.reports.count
  end

  def test_existing_gemfile
    benchmark_code = File.open(fixture_path("sample_benchmark.rb")).read

    build = RailsPerf::Build.new
    build.target = [['sqlite3']]
    RailsPerf.storage.insert_build(build)

    assert_equal 0, RailsPerf.storage.reports.count

    RailsPerf::Jobs::BenchmarkJob.new.perform(build.id, Base64.encode64(benchmark_code))

    assert_equal 1, RailsPerf.storage.reports.count
  end

  def test_custom_gemfile
    benchmark_code = <<-RUBY
require 'bundler/setup'
require 'json'
require 'rails'
result = { version: Rails.version }
puts result.to_json
RUBY

    target = [
      ["arel", {github: 'rails/arel'}],
      ["rails", {github: 'rails/rails', ref: 'e54719df66f455c11a03a5cfa128025c8b00f141'}]
    ]

    build = RailsPerf::Build.new
    build.target = target
    RailsPerf.storage.insert_build(build)

    assert_equal 0, RailsPerf.storage.reports.count

    RailsPerf::Jobs::BenchmarkJob.new.perform(build.id, Base64.encode64(benchmark_code))

    assert_equal 1, RailsPerf.storage.reports.count

    inserted = RailsPerf.storage.reports.find_one
    assert_equal "5.0.0.alpha", inserted["version"]
    assert_equal build.id, inserted["build_id"].to_s
  end

  def test_rails_with_gemfile_builder
    benchmark_code = <<-RUBY
require 'bundler/setup'
require 'json'
require 'active_record'
result = { version: ActiveRecord::VERSION::STRING }
puts result.to_json
RUBY

    build = RailsPerf::Build.new
    build.target = [['activerecord', '3.2.8']]
    RailsPerf.storage.insert_build(build)

    assert_equal 0, RailsPerf.storage.reports.count

    RailsPerf::Jobs::BenchmarkJob.new.perform(build.id, Base64.encode64(benchmark_code))

    assert_equal 1, RailsPerf.storage.reports.count

    inserted = RailsPerf.storage.reports.find_one
    assert_equal "3.2.8", inserted["version"]
    assert_equal build.id, inserted["build_id"].to_s
  end

  def test_custom_benchmark
    benchmark_code = <<-RUBY
require 'json'
result = { inserted: 'data', versions: ['3.2', '4.0']}
puts result.to_json
RUBY

    gemfile_code = File.open(fixture_path("sample_gemfile.rb")).read

    assert_equal 0, RailsPerf.storage.reports.count

    build = RailsPerf::Build.new
    build.target = [['sqlite3']]

    assert_equal 0, RailsPerf.storage.builds.count
    RailsPerf.storage.insert_build(build)
    assert_equal 1, RailsPerf.storage.builds.count

    RailsPerf::Jobs::BenchmarkJob.new.perform(build.id, Base64.encode64(benchmark_code))

    assert_equal 1, RailsPerf.storage.reports.count
    assert_equal 1, RailsPerf.storage.builds.count

    inserted = RailsPerf.storage.reports.find_one
    assert_equal "data", inserted["inserted"]
    assert_equal ['3.2', '4.0'], inserted["versions"]
    assert_equal build.id, inserted["build_id"].to_s
  end

  def test_ruby_version
    benchmark_code = <<-RUBY
require 'json'
res = { mri: RUBY_VERSION }
puts res.to_json
RUBY

    build = RailsPerf::Build.new
    build.target = []
    RailsPerf.storage.insert_build(build)

    assert_equal 0, RailsPerf.storage.reports.count

    RailsPerf::Jobs::BenchmarkJob.new.perform(build.id, Base64.encode64(benchmark_code))

    assert_equal 1, RailsPerf.storage.reports.count

    inserted = RailsPerf.storage.reports.find_one
    assert build.ruby_version.present?
    assert_equal build.ruby_version, inserted["mri"]
  end
end
