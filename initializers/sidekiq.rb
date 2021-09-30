Sidekiq.configure_server do |config|
  config.redis = { url: Settings.sidekiq.redis.url, password: Settings.sidekiq.redis.password }
end

Sidekiq.configure_client do |config|
  config.redis = { url: Settings.sidekiq.redis.url, password: Settings.sidekiq.redis.password }
end
