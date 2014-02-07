class AddPaperclipDiffImageToSnapshot < ActiveRecord::Migration
  def change
    add_attachment :snapshots, :diff_image
  end
end
