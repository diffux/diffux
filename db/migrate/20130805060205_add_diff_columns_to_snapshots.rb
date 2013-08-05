class AddDiffColumnsToSnapshots < ActiveRecord::Migration
  def change
    add_column :snapshots, :diff_external_image_id, :string
    add_column :snapshots, :diff_from_previous, :integer
  end
end
