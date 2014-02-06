class ManualMigrations
  def self.move_snapshot_images!
    Snapshot.all.each do |snapshot|
      if snapshot.image?
        puts "(Re)processing snapshot #{snapshot.id}"
        snapshot.image.reprocess! :thumb
      else
        puts "Processing snapshot #{snapshot.id}"
        begin
          snapshot.image = URI.parse(snapshot.sample_image_url)
          snapshot.save!
        rescue
          puts "Failed to save snapshot #{snapshot.id}"
          puts "Errors: #{snapshot.errors.full_messages.join(', ')}"
        end
      end

      if !snapshot.diff_image? && snapshot.diff_external_image_id?
        puts "Processing diff for snapshot #{snapshot.id}"
        begin
          snapshot.diff_image = URI.parse(
            Cloudinary::Utils.cloudinary_url(snapshot.diff_image_name))
          snapshot.save!
        rescue NameError
          puts "Failed to save diff for snapshot #{snapshot.id}"
          puts "Errors: #{snapshot.errors.full_messages.join(', ')}"
        end
      end
    end
  end
end
