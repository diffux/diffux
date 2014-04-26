# Worker that takes care of creating a snapshot image
class SnapshotterWorker < SnapshotWorker
  def perform(snapshot_id)
    return unless set_snapshot snapshot_id

    FileUtil.with_tempfile do |file|
      snapshotter = Diffux::Snapshotter.new(
        viewport_width: @snapshot.viewport.width,
        user_agent:     @snapshot.viewport.user_agent,
        outfile:        file,
        url:            @snapshot.url.address)
      snapshot = snapshotter.take_snapshot!

      Rails.logger.info <<-EOS
        Saving snapshot of #{@snapshot.url} @ #{@snapshot.viewport}
      EOS

      save_file_to_snapshot(@snapshot, file)
      @snapshot.title = snapshot[:title]
      @snapshot.log   = snapshot[:log]
    end

    @snapshot.save!
  end

  private

  def save_file_to_snapshot(snapshot, file)
    File.open(file) { |f| snapshot.image = f }
  end
end
