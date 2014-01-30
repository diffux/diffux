class AddStatusTimestampsToSnapshots < ActiveRecord::Migration
  def change
    add_column :snapshots, :accepted_at, :timestamp
    add_column :snapshots, :rejected_at, :timestamp
  end
end
