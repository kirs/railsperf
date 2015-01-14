require 'rails-perf'
module RailsPerf
  class VersionRange
    def to_a
      reports.aggregate([{"$group" => {_id: "$component"}}]).map { |m|
        m.values.first.to_s
      }
    end

    private

    def reports
      RailsPerf.storage.reports
    end
  end
end
