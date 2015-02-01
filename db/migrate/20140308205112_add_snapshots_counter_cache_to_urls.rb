class AddSnapshotsCounterCacheToUrls < ActiveRecord::Migration
  def up
    add_column :urls, :snapshots_count, :integer, default: 0

    Url.reset_column_information
    Url.find_each do |url|
      Url.update_counters url.id, snapshots_count: url.snapshots.length
    end
  end

  def down
    remove_column :urls, :snapshots_count
  end
end
