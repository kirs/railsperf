require 'test_helper'

require 'bson'
require 'rails-perf/report_chart_mapper'

class TestReportChartMapper < Minitest::Test

  def test_mapper
    result = RailsPerf::ReportChartMapper.new.map(input)

    assert_equal 3, result.size
    assert_equal ["Model#id", "Model#last", "Model#first"], result.map { |m| m[0] }

    result.each do |r|
      assert_equal ["3.2.0", "4.1.0", "4.2.0", "current"], r[1].map { |m| m[:label] }
      assert r[1].all? { |m| m[:ips].present? }
    end

    assert result.all? { |r| r[1].last[:current] }
  end

  def input
   [{"_id"=>BSON::ObjectId('54b51cf0c86249f03f000003'),
    "build_id"=>"54b51cf0c86249f03f000001",
    "component"=>:activerecord,
    "version"=>"3.2.0",
    "entries"=>
     [{"label"=>"Model#id",
       "iterations"=>17977710,
       "ips"=>1818249.4567441824,
       "ips_sd"=>181640},
      {"label"=>"Model#last",
       "iterations"=>17977710,
       "ips"=>1818249.4567441824,
       "ips_sd"=>181640},
      {"label"=>"Model#first",
       "iterations"=>17977710,
       "ips"=>1818249.4567441824,
       "ips_sd"=>181640}]},
   {"_id"=>BSON::ObjectId('54b51cf0c86249f03f000006'),
    "build_id"=>"54b51cf0c86249f03f000004",
    "component"=>:activerecord,
    "version"=>"4.1.0",
    "entries"=>
     [{"label"=>"Model#id",
       "iterations"=>17977710,
       "ips"=>1818249.4567441824,
       "ips_sd"=>181640},
      {"label"=>"Model#last",
       "iterations"=>17977710,
       "ips"=>1818249.4567441824,
       "ips_sd"=>181640},
      {"label"=>"Model#first",
       "iterations"=>17977710,
       "ips"=>1818249.4567441824,
       "ips_sd"=>181640}]},
   {"_id"=>BSON::ObjectId('54b51cf0c86249f03f000009'),
    "build_id"=>"54b51cf0c86249f03f000007",
    "component"=>:activerecord,
    "version"=>"4.2.0",
    "entries"=>
     [{"label"=>"Model#id",
       "iterations"=>17977710,
       "ips"=>1818249.4567441824,
       "ips_sd"=>181640},
      {"label"=>"Model#last",
       "iterations"=>17977710,
       "ips"=>1818249.4567441824,
       "ips_sd"=>181640},
      {"label"=>"Model#first",
       "iterations"=>17977710,
       "ips"=>1818249.4567441824,
       "ips_sd"=>181640}]},
   {"_id"=>BSON::ObjectId('54b51cf0c86249f03f00000b'),
    "build_id"=>"54b51cf0c86249f03f00000a",
    "component"=>:activerecord,
    "version"=>"5.0.0beta",
    "current"=>true,
    "entries"=>
     [{"label"=>"Model#id",
       "iterations"=>17977710,
       "ips"=>1818249.4567441824,
       "ips_sd"=>181640},
      {"label"=>"Model#last",
       "iterations"=>17977710,
       "ips"=>1818249.4567441824,
       "ips_sd"=>181640},
      {"label"=>"Model#first",
       "iterations"=>17977710,
       "ips"=>1818249.4567441824,
       "ips_sd"=>181640}]}]
  end
end
