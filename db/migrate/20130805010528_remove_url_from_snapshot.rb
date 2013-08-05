class RemoveUrlFromSnapshot < ActiveRecord::Migration
  def change
    remove_column :snapshots, :url
  end
end
