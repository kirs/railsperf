require 'test_helper'
require 'rails-perf/gemfile_builder'

class TestGemfileBuilder < Minitest::Test
  def setup
    @builder = RailsPerf::GemfileBuilder.new
  end

  def test_github_commit
    result = @builder.build([
      ['rails', { source: 'github', commit: 'abc' }],
      ['sqlite3']
    ])

    expected = <<-MSG
source "https://rubygems.org"

gem "rails", source: "github", commit: "abc"
gem "sqlite3"

gem "benchmark-ips", github: "kirs/benchmark-ips"
MSG

    assert_equal expected, result
  end

  def test_github_commit
    result = @builder.build([
      ['rails', '~> 4.2.0'],
      ['sqlite3']
    ])

    expected = <<-MSG
source "https://rubygems.org"

gem "rails", "~> 4.2.0"
gem "sqlite3"

gem "benchmark-ips", github: "kirs/benchmark-ips"
MSG

    assert_equal expected, result
  end
end
