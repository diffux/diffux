# Utility methods for file-related operations.
class FileUtil
  def self.with_tempfile
    Dir.mktmpdir do |dir|
      random_name = (0...8).map { (65 + rand(26)).chr }.join
      yield("#{dir}/#{random_name}.png")
    end
  end

  def self.upload_to_cloudinary(file)
    Cloudinary::Uploader.upload(file)['public_id']
  end
end
