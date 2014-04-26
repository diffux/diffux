require 'open-uri'
# Worker that takes care of comparing the snapshot image against the baseline.
# This worker is responsible for updating the snapshot instance with the result
# of the snapshot comparison.
class SnapshotComparerWorker < SnapshotWorker
  def perform(snapshot_id)
    return unless set_snapshot(snapshot_id)
    return unless @snapshot.compare?

    url          = @snapshot.url
    viewport     = @snapshot.viewport
    compare_with = @snapshot.compared_with || url.baseline(viewport)

    Rails.logger.info "Comparing snapshot of #{url} @ #{viewport} " +
                      'against baseline'
    comparison = Diffux::SnapshotComparer.new(to_chunky_png(compare_with),
                                              to_chunky_png(@snapshot)).compare!
    diff = @snapshot.build_snapshot_diff(comparison.slice(:diff_in_percent))
    diff.before_snapshot = compare_with
    diff_image = comparison[:diff_image]
    if diff_image
      diff.image_height = diff_image.height
      diff.image_width  = diff_image.width
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
      @snapshot.compared_with = compare_with
      @snapshot.save!
    end
  end

  private

  # @param snapshot [Snapshot]
  # @return [ChunkyPNG::Image]
  def to_chunky_png(snapshot)
    case snapshot.image.options[:storage]
    when :s3
      ChunkyPNG::Image.from_io(open(snapshot.image.url))
    when :filesystem
      ChunkyPNG::Image.from_file(snapshot.image.path)
    end
  end
end
