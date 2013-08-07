class AddNameFieldToUrls < ActiveRecord::Migration
  def change
    add_column :urls, :name, :string, nil: false
  end
end
