class RemoveBaselineTable < ActiveRecord::Migration
  def change
    drop_table :baselines
  end
end
