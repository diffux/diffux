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
    comparison = SnapshotComparer.new(@snapshot, baseline).compare!
    diff = @snapshot.build_snapshot_diff(comparison.slice(:diff_in_percent))
    diff.before_snapshot = baseline
    if diff_image = comparison[:diff_image]
      FileUtil.with_tempfile do |tempfile|
        diff_image.save(tempfile)
        diff.image = File.open(tempfile)
      end
    end
    @snapshot.accept if diff.diff_in_percent == 0

    diff.save!
    @snapshot.save!
  end
end
