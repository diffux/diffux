class ChangeDiffFromPreviousToDouble < ActiveRecord::Migration
  def change
    change_column :snapshots, :diff_from_previous, :decimal
  end
end
