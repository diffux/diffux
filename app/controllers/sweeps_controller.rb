class SweepsController < ApplicationController
  before_filter :set_project

  def index
    render
  end

  def show
    @sweep = @project.sweeps.find(params[:id])
  end

  def new
    @sweep = @project.sweeps.build
  end

  def create
    @sweep = @project.sweeps.build(sweep_params)
    if @sweep.save
      @sweep.project.urls.each do |url|
        url.project.viewports.each do |viewport|
          @snapshot          = Snapshot.new
          @snapshot.viewport = viewport
          @snapshot.url      = url
          @snapshot.sweep    = @sweep
          @snapshot.save!
        end
      end
      redirect_to [@project, @sweep], notice: 'Sweep was successfully initiated.'
    else
      render action: 'new'
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def sweep_params
    params.require(:sweep).permit(:title, :description)
  end
end
