class AddComparedWithSnapshotToSnapshots < ActiveRecord::Migration
  def up
    add_reference :snapshots, :compared_with, references: :snapshots

    Snapshot.reset_column_information
    Snapshot.all.each do |snapshot|
      snapshot.compared_with = snapshot.snapshot_diff.try(:before_snapshot)
      snapshot.save!
    end
  end

  def down
    remove_reference :snapshots, :compared_with
  end
end
