require 'rails-perf/storage'

module RailsPerf
  def self.storage
    @storage ||= Storage.new
  end
end
