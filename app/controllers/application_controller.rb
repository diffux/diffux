class ApplicationController < ActionController::Base
  protect_from_forgery

  after_filter :maybe_stop_worker, if: -> { Rails.env.production? }

private

  def maybe_stop_worker
    HerokuManager.maybe_stop_worker!
  end
end
