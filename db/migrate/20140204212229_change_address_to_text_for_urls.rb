class ChangeAddressToTextForUrls < ActiveRecord::Migration
  def change
    change_column :urls, :address, :text
  end
end
