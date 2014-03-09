class RemoveDiffFieldsFromSnapshots < ActiveRecord::Migration
  def change
    remove_column      :snapshots, :diffed_with_snapshot_id
    remove_column      :snapshots, :diff_from_previous
    drop_attached_file :snapshots, :diff_image
  end
end
