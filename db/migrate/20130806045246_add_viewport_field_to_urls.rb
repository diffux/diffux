class AddViewportFieldToUrls < ActiveRecord::Migration
  def change
    add_column :urls, :viewport_width, :integer, default: 320
  end
end
