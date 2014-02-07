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
    Snapshotter.new(snapshot).take_snapshot!

    if baseline = url.baseline(viewport)
      Rails.logger.info "Comparing snapshot of #{url} @ #{viewport} " +
                        'against baseline'
      diff = SnapshotComparer.new(snapshot, baseline).compare!
      snapshot.diff_from_previous     = diff[:diff_in_percent]
      snapshot.diffed_with_snapshot   = baseline
      if diff_image = diff[:diff_image]
        FileUtil.with_tempfile do |tempfile|
          diff_image.save(tempfile)
          snapshot.diff_image = File.open(tempfile)
        end
      end
      snapshot.accept! if snapshot.diff_from_previous == 0
    end

    snapshot.save!
  end
end
