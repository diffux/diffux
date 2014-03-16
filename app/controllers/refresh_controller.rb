# Controller that listens to clients polling to refresh elements,
# e.g. snapshot cards
class RefreshController < ApplicationController
  def create
    # Get the current time as soon as possible, to avoid missing updates that
    # might happen between querying and rendering the response
    server_time = Time.now.to_i

    if_modified_since = DateTime.strptime(params[:ifModifiedSince], '%s')
    items = Snapshot.where(id: params[:snapshots])
                    .where('updated_at >= ?', if_modified_since)
                    .map do |snapshot|
      {
        id:   snapshot.id,
        type: 'snapshot',
        html: render_to_string(partial: 'snapshots/snapshot',
                               locals: { snapshot: snapshot })
      }
    end
    render json: { items: items, serverTime: server_time }
  end
end
