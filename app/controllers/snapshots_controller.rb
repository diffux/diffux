class SnapshotsController < ApplicationController
  before_filter :set_snapshot, only: %i[show destroy accept reject]

  def show
    render
  end

  def create
    url = Url.find(params.delete(:url))
    @snapshot = Snapshot.new
    @snapshot.url = url
    @snapshot.external_image_id = Snapshotter.new(url).take_snapshot!
    if url.baseline
      diff = SnapshotComparer.new(@snapshot, url.baseline).compare!
      @snapshot.diff_external_image_id = diff[:external_image_id]
      @snapshot.diff_from_previous     = diff[:diff_in_percent]
      @snapshot.diffed_with_snapshot   = url.baseline
    end
    @snapshot.save!
    redirect_to url, notice: 'Snapshot was successfully created.'
  end

  def destroy
    @snapshot.destroy

    redirect_to @snapshot.url, notice: 'Snapshot was successfully destroyed.'
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
