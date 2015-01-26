$:.push File.expand_path("../lib", __FILE__)
require 'rails-perf'
require 'rails-perf/jobs'

build_id = '54b7cb899f96e313c4000002'
benchmarks = Dir.glob('benchmarks/*')
benchmarks.each do |benchmark|
  benchmark_code = File.open(benchmark).read

  RailsPerf::Jobs::BenchmarkJob.perform_async(build_id, Base64.encode64(benchmark_code))
end


AeWee8Jo
