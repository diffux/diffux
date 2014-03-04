ENV['REDISCLOUD_URL'] ||= 'redis://localhost:6379'

Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDISCLOUD_URL'], namespace: 'diffux' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDISCLOUD_URL'], namespace: 'diffux' }
end
