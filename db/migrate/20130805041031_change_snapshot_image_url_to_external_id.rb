class ChangeSnapshotImageUrlToExternalId < ActiveRecord::Migration
  def change
    remove_column :snapshots, :image_url
    add_column :snapshots, :external_image_id, :string
  end
end
