require 'sidekiq/api'
require 'heroku-api'

# Hack to only spawn a worker thread on Heroku when we absolutely need to - i.e.
# when there are snapshots to be made.
#
# This is super hacky and is built on the assumption that there is only one web
# process running at a time.
class HerokuManager
  class << self
    def enqueue_snapshot!
      start_worker!
    end

    def maybe_stop_worker!
      return unless ENV['HEROKU_APP_NAME'] && Rails.env.production?

      stop_worker! if Sidekiq::Queue.new.size == 0 &&
                      Sidekiq::Workers.new.size == 0
    end

  private

    def client
      @_client ||= Heroku::API.new(api_key: ENV['HEROKU_API_KEY'])
    end

    def stop_worker!
      client.post_ps_scale(ENV['HEROKU_APP_NAME'], 'worker', 0)
    end

    def start_worker!
      client.post_ps_scale(ENV['HEROKU_APP_NAME'], 'worker', 1)
    end
  end
end
