class SnapshotsController < ApplicationController
  before_filter :set_snapshot, only: %i[show destroy accept reject]

  def show
    render
  end

  def create
    url = Url.find(params.delete(:url))

    url.project.viewports.each do |viewport|
      @snapshot          = Snapshot.new
      @snapshot.viewport = viewport
      @snapshot.url      = url
      @snapshot.save!
      SnapshotWorker.perform_in(2.seconds, @snapshot.id)
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
    flash[:notice] = <<-EOS
      Snapshot has been marked as rejected.
    EOS
    redirect_to @snapshot
  end

  def accept
    @snapshot.accept!
    flash[:notice] = <<-EOS
      Snapshot has been accepted and will now be used
      as the baseline in future diffs for the same URL.
    EOS
    redirect_to @snapshot
  end

  private

  def set_snapshot
    @snapshot = Snapshot.find(params[:id])
  end
end
