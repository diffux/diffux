require 'phantomjs'
require 'json'

class Snapshotter
  SCRIPT_PATH = Rails.root.join('script', 'take-snapshot.js').to_s

  def initialize(url)
    @url = url
  end

  # @return [Hash]
  def take_snapshot!
    result = {}

    FileUtil.with_tempfile do |snapshot_file|
      opts = {
        address: @url.address,
        outfile: snapshot_file,
        viewportSize: {
          width:  @url.viewport_width,
          height: viewport_height
        }
      }

      Phantomjs.run(SCRIPT_PATH, opts.to_json) do |line|
        begin
          result = JSON.parse line
        rescue JSON::ParserError
          # We only expect a single line of JSON to be output by our snapshot
          # script. If something else is happening, we want to know about it.
          raise line
        end
      end

      result[:external_image_id] = FileUtil.upload_to_cloudinary(snapshot_file)
    end

    result
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
