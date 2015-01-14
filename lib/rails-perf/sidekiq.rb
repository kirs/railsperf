require 'sidekiq'
require 'rails-perf/jobs'

module RailsPerf
  SK_NAMESPACE = 'rails_perf'

  # If your client is single-threaded, we just need a single connection in our Redis connection pool
  Sidekiq.configure_client do |config|
    config.redis = { namespace: SK_NAMESPACE, size: 1 }
  end

  # Sidekiq server is multi-threaded so our Redis connection pool size defaults to concurrency (-c)
  Sidekiq.configure_server do |config|
    config.redis = { namespace: SK_NAMESPACE }
  end
end
