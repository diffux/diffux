# Worker that takes care of creating a snapshot image
class SnapshotterWorker < SnapshotWorker
  def perform(snapshot_id)
    return unless set_snapshot snapshot_id
    Snapshotter.new(@snapshot).take_snapshot!
  end
end
