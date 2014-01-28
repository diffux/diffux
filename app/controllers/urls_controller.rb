class UrlsController < ApplicationController
  def index
    @urls = Url.all
  end

  def show
    @url = Url.find(params[:id])
  end

  def new
    @url = Url.new
  end

  def edit
    @url = Url.find(params[:id])
  end

  def create
    @url = Url.new(url_params)
    if @url.save
      redirect_to @url, notice: 'Url was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    @url = Url.find(params[:id])
    if @url.update_attributes(url_params)
      redirect_to @url, notice: 'Url was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @url = Url.find(params[:id])
    @url.destroy
    redirect_to urls_url
  end

  private

  def url_params
    params.require(:url).permit(:address, :viewport_width, :name, :active)
  end
end
