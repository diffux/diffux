# RESTful controller for Url model.
class UrlsController < ApplicationController
  before_filter :set_url

  def show
    render
  end

  def slideshow
    @viewport  = Viewport.find(params[:viewport_id])
    @snapshots = @url.snapshots.where(viewport_id: @viewport)
                               .where('accepted_at is not null')
  end

  def destroy
    @url.destroy
    redirect_to :back, notice: 'Url was successfully destroyed.'
  end

  private

  def set_url
    @url = Url.find(params[:id])
  end
end
