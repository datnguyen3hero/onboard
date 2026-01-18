# frozen_string_literal: true

Sidekiq.configure_server do |config|
  config.redis = {
    url: 'redis://127.0.0.1:6379'
  }
  # config to pull task s from scheduled set every 10 seconds
  config.average_scheduled_poll_interval = 10
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: 'redis://127.0.0.1:6379'
  }
end