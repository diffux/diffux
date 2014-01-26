class AddDiffedWithSnapshot < ActiveRecord::Migration
  def change
    change_table :snapshots do |t|
      t.belongs_to :diffed_with_snapshot
    end
  end
end
