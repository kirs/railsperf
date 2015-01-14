require 'test_helper'
require 'rails-perf/queries'

class TestQueries < Minitest::Test
  def setup
    DbCleaner.run
  end

  def test_facet
    insert_global_builds
    build = insert_current_build

    component = :activerecord

    facet = RailsPerf::Queries::BuildReports.new(build, component)
    data = facet.fetch

    assert_equal 4, data.size

    assert_equal ["3.2.0", "4.1.0", "4.2.0", "5.0.0beta"], data.map { |d| d["version"] }
    assert data.all? { |d| d["component"] == component }
    assert data.all? { |d| d["entries"].size == 3 }
  end

  def insert_global_builds
    ['3.2.0', '4.1.0', '4.2.0'].each do |v|
      build = RailsPerf::Build.new
      build.target = [['activerecord', v]]
      build.global = true
      RailsPerf.storage.insert_build(build)

      RailsPerf.storage.reports.insert({build_id: build.id, "component"=>:router, "version"=>v, "entries"=>[
        {"label"=>"Router#id", "iterations"=>17977710, "ips"=>1818249.4567441824, "ips_sd"=>181640},
        {"label"=>"Router#last", "iterations"=>17977710, "ips"=>1818249.4567441824, "ips_sd"=>181640},
        {"label"=>"Router#first", "iterations"=>17977710, "ips"=>1818249.4567441824, "ips_sd"=>181640}
      ]})
      RailsPerf.storage.reports.insert({build_id: build.id, "component"=>:activerecord, "version"=>v, "entries"=>[
        {"label"=>"Model#id", "iterations"=>17977710, "ips"=>1818249.4567441824, "ips_sd"=>181640},
        {"label"=>"Model#last", "iterations"=>17977710, "ips"=>1818249.4567441824, "ips_sd"=>181640},
        {"label"=>"Model#first", "iterations"=>17977710, "ips"=>1818249.4567441824, "ips_sd"=>181640}
      ]})
    end
  end

  def insert_current_build
    build = RailsPerf::Build.new
    build.title = 'Commit abc'
    build.global = false
    build.target = [['activerecord', { ref: 'abc' }]]

    RailsPerf.storage.insert_build(build)
    RailsPerf.storage.reports.insert({build_id: build.id, "component"=>:activerecord, "version"=>"5.0.0beta", "entries"=>[
      {"label"=>"Model#id", "iterations"=>17977710, "ips"=>1818249.4567441824, "ips_sd"=>181640},
      {"label"=>"Model#last", "iterations"=>17977710, "ips"=>1818249.4567441824, "ips_sd"=>181640},
      {"label"=>"Model#first", "iterations"=>17977710, "ips"=>1818249.4567441824, "ips_sd"=>181640}
      ]})

    build
  end
end
