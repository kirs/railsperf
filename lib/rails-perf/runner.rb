require 'fileutils'
require 'rails-perf'
require 'rails-perf/jobs'

module RailsPerf
  class Runner
    def execute(options)
      build = Build.new.tap do |b|
        b.target = options[:target] # or raise
        b.tag = options[:tag] # or raise
        b.global = !!options[:global]
      end

      RailsPerf.storage.insert_build(build)

      enqueue_jobs(build)

      build
    end

    private

    def enqueue_jobs(build)
      if build.id.blank?
        raise ArgumentError, "build id is blank"
      end

      benchmarks = Dir.glob('benchmarks/*')
      benchmarks.each do |benchmark|
        benchmark_code = File.open(benchmark).read
        RailsPerf::Jobs::BenchmarkJob.perform_async(build.id, Base64.encode64(benchmark_code))
      end
    end
  end
end
