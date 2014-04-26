# Snapshotter is responsible for delegating to PhantomJS to take the snapshot
# for a given URL and viewoprt, and then saving that snapshot to a file and
# storing any metadata on the Snapshot object.
class Snapshotter
  SCRIPT_PATH = Rails.root.join('script', 'take-snapshot.js').to_s

  # @param url [String} the URL to snapshot
  # @param viewport_width [Integer] the width of the screen used when
  #   snapshotting
  # @param outfile [File] where to store the snapshot PNG.
  # @param user_agent [String] an optional useragent string to used when
  #   requesting the page.
  def initialize(url:, viewport_width:, outfile:, user_agent: nil)
    @viewport_width = viewport_width
    @user_agent     = user_agent
    @outfile        = outfile
    @url            = url
  end

  # Takes a snapshot of the URL and saves it in the out_file as a PNG image.
  #
  # @return [Hash] a hash containing the following keys:
  #   title [String] the <title> of the page being snapshotted
  #   log   [String] a log of events happened during the snapshotting process
  def take_snapshot!
    result = {}
    opts = {
      address: @url,
      outfile: @outfile,
      viewportSize: {
        width:  @viewport_width,
        height: @viewport_width,
      },
    }
    opts[:userAgent] = @user_agent if @user_agent

    Rails.logger.info "Taking snapshot of #{@url} @ #{@viewport_width}"
    run_phantomjs(opts) do |line|
      begin
        result = JSON.parse line, symbolize_names: true
      rescue JSON::ParserError
        # We only expect a single line of JSON to be output by our snapshot
        # script. If something else is happening, it is likely a JavaScript
        # error on the page and we should just forget about it and move on
        # with our lives.
      end
    end
    result
  end

  private

  def run_phantomjs(options)
    Phantomjs.run('--ignore-ssl-errors=true',
                  SCRIPT_PATH, options.to_json) do |line|
      yield line
    end
  end
end
