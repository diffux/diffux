class AddSnapshotCountersToSweep < ActiveRecord::Migration
  def change
    add_column :sweeps, :count_pending,      :integer, default: 0
    add_column :sweeps, :count_accepted,     :integer, default: 0
    add_column :sweeps, :count_rejected,     :integer, default: 0
    add_column :sweeps, :count_under_review, :integer, default: 0
  end
end
