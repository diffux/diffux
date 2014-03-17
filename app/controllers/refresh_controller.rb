# Controller that listens to clients polling to refresh elements,
# e.g. snapshot cards
class RefreshController < ApplicationController
  REFRESHERS = [{
                  param_name: 'snapshots',
                  class:      Snapshot,
                  renderer:   ->(item, controller) {
                    controller.render_to_string(partial: 'snapshots/snapshot',
                                                locals:  { snapshot: item })
                  }
                },
                {
                  param_name: 'sweeps',
                  class:      Sweep,
                  renderer:   ->(item, controller) {
                    controller.view_context.sweep_progress_bar(item)
                  }
                }]

  def create
    # Get the current time as soon as possible, to avoid missing updates that
    # might happen between querying and rendering the response
    server_time = Time.now.to_i

    if_modified_since = DateTime.strptime(params[:ifModifiedSince], '%s')
    items = []
    REFRESHERS.each do |refresher|
      items.concat(
        refresher[:class]
           .where(id: params[refresher[:param_name]])
           .where('updated_at >= ?', if_modified_since)
           .map do |item|
             {
               id:   item.id,
               type: refresher[:class].name.downcase,
               html: refresher[:renderer].call(item, self)
             }
           end
      )
    end
    render json: { items: items, serverTime: server_time }
  end
end
