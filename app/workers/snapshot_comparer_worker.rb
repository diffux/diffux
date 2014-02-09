# Worker that takes care of comparing the snapshot image against the baseline.
# This worker is responsible for updating the snapshot instance with the result
# of the snapshot comparison.
class SnapshotComparerWorker < SnapshotWorker
  def perform(snapshot_id)
    return unless set_snapshot(snapshot_id)
    return unless @snapshot.compare?

    url      = @snapshot.url
    viewport = @snapshot.viewport
    baseline = url.baseline(viewport)

    Rails.logger.info "Comparing snapshot of #{url} @ #{viewport} " +
                      'against baseline'
    diff = SnapshotComparer.new(@snapshot, baseline).compare!
    @snapshot.diff_from_previous   = diff[:diff_in_percent]
    @snapshot.diffed_with_snapshot = baseline
    if diff_image = diff[:diff_image]
      FileUtil.with_tempfile do |tempfile|
        diff_image.save(tempfile)
        @snapshot.diff_image = File.open(tempfile)
      end
    end
    @snapshot.accept! if @snapshot.diff_from_previous == 0

    @snapshot.save!
  end
end
