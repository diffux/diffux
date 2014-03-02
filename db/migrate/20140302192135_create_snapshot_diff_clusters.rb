class CreateSnapshotDiffClusters < ActiveRecord::Migration
  def change
    create_table :snapshot_diff_clusters do |t|
      t.references :snapshot_diff
      t.integer    :start
      t.integer    :finish
      t.timestamps
    end

    change_table :snapshot_diffs do |t|
      t.integer :image_height
    end
  end
end
