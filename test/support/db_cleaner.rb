require 'rails-perf'

module DbCleaner
  def self.run
    RailsPerf.storage.builds.drop
    RailsPerf.storage.reports.drop
  end
end
