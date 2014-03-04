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
    diff_image = comparison[:diff_image]
    if diff_image
      diff.image_height = diff_image.height
      FileUtil.with_tempfile do |tempfile|
        diff_image.save(tempfile)
        diff.image = File.open(tempfile)
      end
    end
    @snapshot.accept if diff.diff_in_percent == 0

    @snapshot.transaction do
      diff.save!
      comparison[:diff_clusters].each do |cluster|
        diff.snapshot_diff_clusters.create!(cluster)
      end
      @snapshot.save!
    end
  end
end
