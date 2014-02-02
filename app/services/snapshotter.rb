require 'phantomjs'
require 'json'

class Snapshotter
  SCRIPT_PATH = Rails.root.join('script', 'take-snapshot.js').to_s

  def initialize(url, viewport)
    @url      = url
    @viewport = viewport
  end

  # @return [Hash]
  def take_snapshot!
    result = {}

    FileUtil.with_tempfile do |snapshot_file|
      opts = {
        address: @url.address,
        outfile: snapshot_file,
        viewportSize: {
          width:  @viewport.width,
          height: @viewport.height
        }
      }

      Rails.logger.info "Taking snapshot of #{@url} @ #{@viewport}"
      Phantomjs.run(SCRIPT_PATH, opts.to_json) do |line|
        begin
          result = JSON.parse line, symbolize_names: true
        rescue JSON::ParserError
          # We only expect a single line of JSON to be output by our snapshot
          # script. If something else is happening, we want to know about it.
          raise line
        end
      end

      Rails.logger.info "Uploading snapshot of #{@url} @ #{@viewport}"
      result[:external_image_id] = FileUtil.upload_to_cloudinary(snapshot_file)
    end

    result
  end
end
