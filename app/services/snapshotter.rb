require 'phantomjs'

class Snapshotter
  def initialize(url)
    @url = url
  end

  def take_snapshot!
    FileUtil.with_tempfile do |snapshot_file|
      opts = {
        address: @url.address,
        outfile: snapshot_file,
        viewportSize: {
          width:  @url.viewport_width,
          height: viewport_height
        }
      }
      Phantomjs.run(Rails.root.join('script', 'take-snapshot.js').to_s,
                    opts.to_json) do |line|
        puts line
      end
      FileUtil.upload_to_cloudinary(snapshot_file)
    end
  end

  private

  # @return [Integer]
  def viewport_height
    if @url.viewport_width < 960
      @url.viewport_width * 2
    else
      (@url.viewport_width * 0.75).round # 16:12
    end
  end
end
