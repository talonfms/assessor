require "sidekiq/api"

redis_url = Rails.env.development? ? "redis://localhost:6379/1" : ENV["REDISCLOUD_URL"]

Sidekiq.configure_server do |config|
  config.redis = {url: redis_url}
end

Sidekiq.configure_client do |config|
  config.redis = {url: redis_url}
end
