class RemoveNameFromUrl < ActiveRecord::Migration
  def change
    remove_column :urls, :name, :string, nil: false
  end
end
