class SnapshotsController < ApplicationController
  before_filter :set_snapshot, only: %i[show destroy set_as_baseline]

  def show
    render
  end

  def create
    url = Url.find(params.delete(:url))
    @snapshot = Snapshot.new
    @snapshot.url = url
    @snapshot.external_image_id = Snapshotter.new(url).take_snapshot!
    if url.baseline
      diff = SnapshotComparer.new(@snapshot, url.baseline.snapshot).compare!
      @snapshot.diff_external_image_id = diff[:external_image_id]
      @snapshot.diff_from_previous     = diff[:diff_in_percent]
      @snapshot.diffed_with_snapshot   = url.baseline.snapshot
    end
    @snapshot.save!
    redirect_to url, notice: 'Snapshot was successfully created.'
  end

  def destroy
    @snapshot.destroy

    redirect_to @snapshot.url, notice: 'Snapshot was successfully destroyed.'
  end

  def set_as_baseline
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

  private

  def set_snapshot
    @snapshot = Snapshot.find(params[:id])
  end
end
