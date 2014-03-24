class AddImageWidthToSnapshotDiffs < ActiveRecord::Migration
  def change
    add_column :snapshot_diffs, :image_width, :integer
  end
end
