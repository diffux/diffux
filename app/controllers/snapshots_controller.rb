class SnapshotsController < ApplicationController
  before_filter :set_snapshot, only: %i[show destroy accept reject]

  def show
    render
  end

  def create
    url = Url.find(params.delete(:url))

    url.project.viewports.each do |viewport|
      snapshot_result = Snapshotter.new(url, viewport).take_snapshot!

      @snapshot                   = Snapshot.new
      @snapshot.viewport          = viewport
      @snapshot.url               = url
      @snapshot.title             = snapshot_result[:title]
      @snapshot.external_image_id = snapshot_result[:external_image_id]

      if baseline = url.baseline(viewport)
        Rails.logger.info "Comparing snapshot of #{url} @ #{viewport} " +
                          'against baseline'
        diff = SnapshotComparer.new(@snapshot, baseline).compare!
        @snapshot.diff_from_previous     = diff[:diff_in_percent]
        @snapshot.diffed_with_snapshot   = baseline
        if diff_image = diff[:diff_image]
          @snapshot.diff_external_image_id = FileUtil.upload_png(diff_image)
        end
        @snapshot.accept! if @snapshot.diff_from_previous == 0
      end

      @snapshot.save!
    end

    redirect_to url.project, notice: 'Snapshots were successfully created.'
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
