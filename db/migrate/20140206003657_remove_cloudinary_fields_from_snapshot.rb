class RemoveCloudinaryFieldsFromSnapshot < ActiveRecord::Migration
  def change
    remove_column :snapshots, :external_image_id
    remove_column :snapshots, :diff_external_image_id
  end
end
