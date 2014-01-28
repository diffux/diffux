class UrlsController < ApplicationController
  before_filter :set_url, only: %i[show edit update destroy]

  def index
    @urls = Url.all
  end

  def show
    render
  end

  def new
    @url = Url.new
  end

  def edit
    render
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
    if @url.update_attributes(url_params)
      redirect_to @url, notice: 'Url was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @url.destroy
    redirect_to urls_url, notice: 'Url was successfully destroyed.'
  end

  private

  def set_url
    @url = Url.find(params[:id])
  end

  def url_params
    params.require(:url).permit(:address, :viewport_width, :name, :active)
  end
end
