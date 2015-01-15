require 'rails-perf'

module RailsPerf
  class BuildStatus
    def initialize(build)
      @build = build
    end

    def ready?
      reports_count > 0
    end

    private

    def reports_count
      RailsPerf.storage.reports.find(build_id: @build.id).count
    end
  end
end
