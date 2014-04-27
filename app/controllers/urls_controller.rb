# RESTful controller for Url model.
class UrlsController < ApplicationController
  before_filter :set_url, only: %i[show destroy]

  def show
    render
  end

  def destroy
    @url.destroy
    redirect_to :back,
                notice: t(:model_destroyed,
                          model_name: @url.class.model_name.human)
  end

  private

  def set_url
    @url = Url.find(params[:id])
  end
end
