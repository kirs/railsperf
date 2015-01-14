require 'test_helper'
require 'rails-perf'
require 'rails-perf/runner'
require 'rails-perf/jobs'

class TestRunner < Minitest::Test
  def setup
    Sidekiq::Worker.clear_all
    DbCleaner.run
  end

  def test_run
    assert_equal 0, RailsPerf::Jobs::BenchmarkJob.jobs.size
    assert_equal 0, RailsPerf.storage.builds.size

    target = [
      ['rails', '~> 3.2.21'],
      ['sqlite3']
    ]

    RailsPerf::Runner.new.execute({ target: target })

    assert_equal 1, RailsPerf.storage.builds.size
    assert_equal 2, RailsPerf::Jobs::BenchmarkJob.jobs.size

    build = RailsPerf.storage.builds.find_one
    assert_equal target, build["target"]

    args = RailsPerf::Jobs::BenchmarkJob.jobs.map { |cl| cl["args"][0] }
    assert args.all? { |a| a == build["_id"].to_s }
  end
end
