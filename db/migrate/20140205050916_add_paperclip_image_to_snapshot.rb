class AddPaperclipImageToSnapshot < ActiveRecord::Migration
  def change
    add_attachment :snapshots, :image
  end
end
