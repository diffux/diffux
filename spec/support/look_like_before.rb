require 'rspec'

# RSpec matcher that checks for style regressions.
#
# @example
#   expect { url }.to look_like_before
#
# @example
#   expect { url }.to look_like_before(width: 1200)
RSpec::Matchers.define :look_like_before do |options = {}|
  width = options[:at_width] || 1200

  def take_snapshot(url, width, outfile, crop_selector)
    snapshot_result = Diffux::Snapshotter.new(
      viewport_width: width,
      crop_selector: crop_selector,
      outfile: outfile,
      url: url,
    ).take_snapshot!
    fail 'Got `nil` back from taking the snapshot' unless snapshot_result
  end

  def compare(before, after)
    Diffux::SnapshotComparer.new(
      ChunkyPNG::Image.from_file(before),
      ChunkyPNG::Image.from_file(after)
    ).compare!
  end

  match do |path|
    page.current_url # Magic trickery to make Capybara do what we want

    # I can't figure out why using the url helpers give me
    # "http://www.example.com" back. This is hacky, and will probably have to
    # change at some point.
    url = "http://localhost:#{Capybara.server_port}" + path

    @example_desc    = example.metadata[:example_group][:full_description]
    unique_name      = "#{@example_desc}@#{width}@#{options[:crop_selector]}"
    safe_unique_name = unique_name.gsub(/[^a-zA-Z0-9@#]/, '_')
    @diff               = "diffux/#{safe_unique_name}_diff.png"
    @baseline           = "diffux/#{safe_unique_name}_baseline.png"
    @baseline_candidate = "diffux/#{safe_unique_name}_baseline_candidate.png"

    if File.exist?(@baseline)
      take_snapshot(url, width, @baseline_candidate, options[:crop_selector])
      diff_image = compare(@baseline, @baseline_candidate)[:diff_image]
      if diff_image
        diff_image.save(@diff)
        false
      else
        File.delete(@baseline_candidate) # Clean up before returning.
        true
      end
    else
      puts <<-EOS
        ******* DIFFUX ********
        Snapshotting "#{@example_desc}" for the first time. You should check the
        output saved to #{@baseline}. If it looks ok, commit it to the
        repository.
      EOS
      take_snapshot(url, width, @baseline, options[:crop_selector])
      true
    end
  end

  failure_message_for_should do |url|
    <<-EOS
      ******* DIFFUX ********
      Expected "#{@example_desc}" to look like the stored baseline. Have a look
      at the saved diff (#{@diff}). If the diff looks ok, replace the baseline
      image with the new (#{@baseline_candidate}):

        mv --force #{@baseline_candidate} #{@baseline}; rm #{@diff}

      If the diff does not look ok, a visual regression might have been
      introduced. In that case, you should try to identify what's wrong and fix
      it.
    EOS
  end
end
