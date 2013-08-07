class AddActiveFieldToUrls < ActiveRecord::Migration
  def change
    add_column :urls, :active, :boolean, default: true
  end
end
