class SnapshotsController < ApplicationController
  def index
    if params[:url]
      @url = Url.find(params[:url])
      @snapshots = @url.snapshots
    else
      @snapshots = Snapshot.all
    end
  end

  def show
    @snapshot = Snapshot.find(params[:id])
  end

  def create
    url = Url.find(params.delete(:url))
    @snapshot = Snapshot.new
    @snapshot.url = url

    @snapshot.save!
    redirect_to url, notice: 'Snapshot was successfully created.'
  end

  def destroy
    @snapshot = Snapshot.find(params[:id])
    @snapshot.destroy

    redirect_to @snapshot.url
  end

  def set_as_baseline
    @snapshot = Snapshot.find(params[:id])
    baseline  = Baseline.where(url_id: @snapshot.url.id).first ||
                Baseline.new(url_id: @snapshot.url.id)
    baseline.snapshot = @snapshot
    baseline.save!

    flash[:notice] = <<-EOS
      This Snapshot will now be used as the baseline
      in future diffs for the same URL.
    EOS
    redirect_to @snapshot
  end
end
