class UrlsController < ApplicationController
  before_filter :set_url, only: %i[destroy]

  def destroy
    @url.destroy
    redirect_to :back, notice: 'Url was successfully destroyed.'
  end

  private

  def set_url
    @url = Url.find(params[:id])
  end
end
