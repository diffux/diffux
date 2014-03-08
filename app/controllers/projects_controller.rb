# RESTful controller for Project model.
class ProjectsController < ApplicationController
  before_filter :set_project, only: %i[show edit update destroy]

  def index
    @projects = Project.all.includes(:viewports)
  end

  def show
    render
  end

  def new
    @project = Project.new
  end

  def edit
    render
  end

  def create
    @project = Project.new(project_params)
    if @project.save
      redirect_to @project, notice: 'Project was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    if @project.update_attributes(project_params)
      redirect_to @project, notice: 'Project was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_url, notice: 'Project was successfully destroyed.'
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :viewport_widths, :url_addresses)
  end
end
