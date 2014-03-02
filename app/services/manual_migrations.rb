class ManualMigrations
  def self.move_diff_fields
    Snapshot.all.each do |snapshot|
      next unless snapshot.diffed_with_snapshot
      next if     snapshot.snapshot_diff

      snapshot.transaction do
        snapshot.create_snapshot_diff!(
          image:              snapshot.diff_image,
          diff_in_percent:    snapshot.diff_from_previous,
          before_snapshot_id: snapshot.diffed_with_snapshot.id
        )
        snapshot.diffed_with_snapshot = nil
        snapshot.diff_from_previous   = nil
        snapshot.diff_image           = nil
        snapshot.save!
      end
    end
  end
end
