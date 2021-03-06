module RailsPerf
  class ReportChartMapper
    def map(reports_hash)
      nodes = reports_hash.map { |r| r["entries"].size }.max - 1

      (0..nodes).map do |i|
        [
          reports_hash.map { |r| r["entries"][i]["label"] }.find(&:present?),
          reports_hash.map { |r|
            current = !!r["current"]
            {
              label: current ? "current" : r["version"],
              ips: r["entries"][i]["ips"],
              current: current
            }
          }
        ]
      end
    end

  end
end
