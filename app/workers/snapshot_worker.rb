# Base class for workers that operate on Snapshots
class SnapshotWorker
  include Sidekiq::Worker

  protected

  # @return [Boolean]
  def set_snapshot(snapshot_id)
    begin
      @snapshot = Snapshot.find(snapshot_id)
      true
    rescue ActiveRecord::RecordNotFound
      # The Snapshot was deleted before the worker could run, so there is
      # nothing left for this worker to do.
      false
    end
  end
end
