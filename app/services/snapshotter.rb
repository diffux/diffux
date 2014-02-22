class Snapshotter
  SCRIPT_PATH = Rails.root.join('script', 'take-snapshot.js').to_s

  def initialize(snapshot)
    @snapshot = snapshot
    @url      = snapshot.url
    @viewport = snapshot.viewport
  end

  # @return [Boolean]
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
      Phantomjs.run('--ignore-ssl-errors=true', SCRIPT_PATH, opts.to_json) do |line|
        begin
          result = JSON.parse line, symbolize_names: true
        rescue JSON::ParserError
          # We only expect a single line of JSON to be output by our snapshot
          # script. If something else is happening, it is likely a JavaScript
          # error on the page and we should just forget about it and move on
          # with our lives.
        end
      end

      Rails.logger.info "Saving snapshot of #{@url} @ #{@viewport}"
      save_file_to_snapshot(@snapshot, snapshot_file)
      @snapshot.title = result[:title]
    end

    @snapshot.save!
  end

  private

  def save_file_to_snapshot(snapshot, file)
    File.open(file) do |f|
      snapshot.image = f
    end
  end
end
