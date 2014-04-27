# RESTful controller for Project model.
class ProjectsController < ApplicationController
  before_filter :set_project, only: %i[show edit update destroy]

  def index
    @projects = Project.order(:name).includes(:viewports, :last_sweep)
  end

  def show
    render
  end

  def new
    @project = Project.new(viewport_widths: "320\n1200",
                           url_addresses:   'http://www.example.com/')
  end

  def edit
    render
  end

  def create
    @project = Project.new(project_params)
    if @project.save
      redirect_to @project,
                  notice: t(:model_destroyed,
                            model_name: @project.class.model_name.human)
    else
      render action: 'new'
    end
  end

  def update
    if @project.update_attributes(project_params)
      redirect_to @project,
                  notice: t(:model_updated,
                            model_name: @project.class.model_name.human)
    else
      render action: 'edit'
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_url,
                notice: t(:model_destroyed,
                          model_name: @project.class.model_name.human)
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :viewport_widths, :url_addresses)
  end
end
