# RESTful controller for Viewport model.
class ViewportsController < ApplicationController
  before_filter :set_viewport

  def edit
    render
  end

  def update
    if @viewport.update_attributes(viewport_params)
      redirect_to @viewport.project,
                  notice: t(:model_updated,
                            model_name: @viewport.class.model_name.human)
    else
      render action: 'edit'
    end
  end

  private

  def viewport_params
    params.require(:viewport).permit(:width, :user_agent)
  end

  def set_viewport
    @viewport = Viewport.find(params[:id])
  end
end
