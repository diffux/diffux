class SnapshotsController < ApplicationController
  before_filter :set_snapshot, only: %i[show destroy accept reject take_snapshot]

  def show
    if snapshot_ids = params[:review_list]
      @review_list = Snapshot.where(id: snapshot_ids)
    end
    render
  end

  def create
    url = Url.find(params.delete(:url))

    url.project.viewports.each do |viewport|
      @snapshot          = Snapshot.new
      @snapshot.viewport = viewport
      @snapshot.url      = url
      @snapshot.save!
    end

    redirect_to url.project, notice: 'Snapshots were successfully created.'
  end

  def destroy
    @snapshot.destroy

    redirect_to @snapshot.url.project,
      notice: 'Snapshot was successfully destroyed.'
  end

  def reject
    @snapshot.reject!
    if request.xhr?
      render partial: 'snapshots/status_block'
    else
      redirect_to @snapshot
    end
  end

  def accept
    @snapshot.accept!
    if request.xhr?
      render partial: 'snapshots/status_block'
    else
      redirect_to @snapshot
    end
  end

  def take_snapshot
    @snapshot.image                = nil
    @snapshot.accepted_at          = nil
    @snapshot.rejected_at          = nil
    @snapshot.snapshot_diff.try(:destroy!)
    @snapshot.snapshot_diff        = nil
    @snapshot.save!

    @snapshot.take_snapshot

    redirect_to @snapshot,
      notice: 'Snapshot is scheduled to be retaken.'
  end

  private

  def set_snapshot
    @snapshot = Snapshot.find(params[:id])
  end
end
