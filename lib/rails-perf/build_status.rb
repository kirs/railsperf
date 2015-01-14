require 'rails-perf/sidekiq'
require 'sidekiq/api'

module RailsPerf
  class BuildStatus
    def initialize(build)
      @build = build
    end

    def ready?
      queue.size.zero?
    end

    private

    def queue
      Sidekiq::Queue.new.select { |job| job.args[0] == @build.id }
    end
  end
end
