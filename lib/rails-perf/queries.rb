require 'rails-perf'
require 'rails-perf/storage'
require 'active_support/core_ext/object/blank'

module RailsPerf
  module Queries
    class Base
      def storage
        RailsPerf.storage
      end
    end

    class AllBuilds < Base
      def fetch
        storage.builds.find.to_a.map do |row|
          Build.new.unserialize(row)
        end
      end
    end

    class ComparedReports < Base
      def fetch(component)
        builds.map { |b|
          storage.reports.find_one(build_id: b["_id"].to_s, component: component)
        }.sort { |a, b| Gem::Version.new(a["version"]) <=> Gem::Version.new(b["version"])}
      end

      def builds
        storage.builds.find(global: true).to_a
      end
    end

    class BuildReports < Base
      class NotProcessedError < StandardError;end

      def initialize(build, component)
        @build = build
        @component = component.to_sym
      end

      def fetch
        compared_reports + current_reports
      end

      private

      def compared_reports
        ComparedReports.new.fetch(@component)
      end

      def current_reports
        records = storage.reports.find(build_id: @build.id, component: @component).to_a

        if records.size.zero?
          raise NotProcessedError
        end

        records.map { |r| r["current"] = true; r }
      end
    end
  end
end
