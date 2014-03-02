class CreateSnapshotDiffs < ActiveRecord::Migration
  def change
    create_table :snapshot_diffs do |t|
      t.attachment :image
      t.decimal    :diff_in_percent
      t.references :before_snapshot
      t.timestamps
    end

    change_table :snapshots do |t|
      t.references :snapshot_diff
    end
  end
end
