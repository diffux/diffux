# Base controller for the Diffux app.
class ApplicationController < ActionController::Base
  protect_from_forgery

  before_action :set_locale

  def default_url_options(options = {})
    return { locale: I18n.locale } if I18n.locale != I18n.default_locale
    {}
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
end
