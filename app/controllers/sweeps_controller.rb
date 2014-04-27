# Mostly RESTful controller for Sweep model.
class SweepsController < ApplicationController
  before_filter :set_project

  def index
    render
  end

  def show
    @sweep = @project.sweeps.find(params[:id])
  end

  def new
    @sweep = @project.sweeps.build(title: t(:sweep_default_title, time: Time.now))
  end

  def create
    if create_sweep
      redirect_to [@project, @sweep], notice: t(:sweep_initiated)
    else
      render action: 'new'
    end
  end

  # Same as #create, but exposed publicly. Parameters are passed in as JSON.
  def trigger
    if create_sweep
      render json: { url: project_sweep_url(@project, @sweep) }
    else
      render json: { errors: @sweep.errors.full_messages }, status: 400
    end
  end

  private

  def create_sweep
    @sweep = @project.sweeps.build(sweep_params)
    @sweep.save
  end

  def set_project
    @project = Project.find(params[:project_id])
  end

  def sweep_params
    params.require(:sweep).permit(:title,
                                  :description,
                                  :delay_seconds,
                                  :email)
  end
end
