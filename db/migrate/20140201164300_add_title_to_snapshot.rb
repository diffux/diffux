class AddTitleToSnapshot < ActiveRecord::Migration
  def change
    add_column :snapshots, :title, :string
  end
end
