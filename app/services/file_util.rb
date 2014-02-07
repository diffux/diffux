# Utility methods for file-related operations.
class FileUtil
  def self.with_tempfile
    Dir.mktmpdir do |dir|
      yield("#{dir}/#{SecureRandom.uuid}.png")
    end
  end
end
