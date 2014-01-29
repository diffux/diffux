class RemoveActiveFromUrl < ActiveRecord::Migration
  def change
    remove_column :urls, :active
  end
end
