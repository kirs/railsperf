require 'rails-perf'
require 'json'
require 'fileutils'
require 'tmpdir'
require 'securerandom'
require 'sidekiq'

module RailsPerf
  module Jobs
    class BenchmarkJob
      include Sidekiq::Worker

      def perform(build_id, benchmark_code)
        benchmark_code = Base64.decode64(benchmark_code)

        @build = RailsPerf.storage.find_build!(build_id)

        begin
          Dir.mktmpdir(dir_id) do |dir|
            dir = Pathname.new(dir)
            @build.logger.info("temp dir created: #{dir}")

            File.open(dir.join('Gemfile'), 'w') do |f|
              f.write @build.gemfile_content
            end

            File.open(dir.join('benchmark.rb'), 'w') do |f|
              f.write benchmark_code
            end

            bundle_out = bundle_relative(dir)
            @build.logger.info("bundle result: #{bundle_out}")

            output = exec_relative(dir)
            @build.logger.info("sample result: #{output}")

            begin
              output = JSON.parse(output).merge("build_id" => @build.id)
              RailsPerf.storage.put(output)
            rescue JSON::ParserError => e
              @build.logger.info "json parse failed: #{e.inspect}"
            end
          end
        ensure
          @build.logger.close
        end
      end

      private

      def bundle_relative(dir)
        cmd = "cd #{dir.to_s} && #{bundle_env(dir)} #{bin_path(:bundle)} install --path #{dir.join('bundle_cache')}"
        execute(cmd)
      end

      def exec_relative(dir)
        cmd = "cd #{dir.to_s} && #{bundle_env(dir)} #{bin_path(:ruby)} benchmark.rb"
        execute(cmd)
      end

      def bundle_env(dir)
        "BUNDLE_GEMFILE=#{dir.join('Gemfile')}"
      end

      def execute(cmd)
        @build.logger.info "executing #{cmd}"
        Bundler.with_clean_env do
          `#{cmd}`
        end
      end

      def bin_path(bin)
        "RBENV_VERSION=#{@build.ruby_version} rbenv exec #{bin}"
      end

      def bundle_cache_path
        Pathname.new(Dir.pwd).join("tmp", "bundle_cache")
      end

      def dir_id
        @dir_id ||= SecureRandom.hex
      end
    end
  end
end
