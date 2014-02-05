# Worker that takes care of creating a snapshot image and comparing that image
# to a previous baseline
class SnapshotWorker
  include Sidekiq::Worker

  def perform(snapshot_id)
    begin
      snapshot = Snapshot.find(snapshot_id)
    rescue ActiveRecord::RecordNotFound
      # The Snapshot was deleted before the worker could run, so there is
      # nothing left for this worker to do.
      return
    end

    url             = snapshot.url
    viewport        = snapshot.viewport
    snapshot_result = Snapshotter.new(url, viewport).take_snapshot!

    snapshot.title             = snapshot_result[:title]
    snapshot.external_image_id = snapshot_result[:external_image_id]

    if baseline = url.baseline(viewport)
      Rails.logger.info "Comparing snapshot of #{url} @ #{viewport} " +
                        'against baseline'
      diff = SnapshotComparer.new(snapshot, baseline).compare!
      snapshot.diff_from_previous     = diff[:diff_in_percent]
      snapshot.diffed_with_snapshot   = baseline
      if diff_image = diff[:diff_image]
        snapshot.diff_external_image_id = FileUtil.upload_png(diff_image)
      end
      snapshot.accept! if snapshot.diff_from_previous == 0
    end

    snapshot.save!
  end
end
