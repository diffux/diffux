require 'phantomjs'
require 'chunky_png'
require 'open-uri'

class Snapshot < ActiveRecord::Base
  include ChunkyPNG::Color
  belongs_to :url
  belongs_to :diffed_with_snapshot, class_name: Snapshot.name
  validates_presence_of :url
  default_scope { order('created_at DESC') }

  before_create :take_snapshot!,
                :compare_with_previous!

  def image_name
    external_image_id + '.png'
  end

  def diff_image_name
    diff_external_image_id + '.png'
  end

  def diff?
    !!diffed_with_snapshot
  end

  def sample_image_url
    # TODO: how do I get access to helper methods here? (`cl_image_path`)

    # Use max 1500 high images, to speed up diff
    "http://res.cloudinary.com/diffux/image/upload/c_fit,h_1000/v1375678803/#{image_name}"
  end

  def to_chunky_png
    ChunkyPNG::Image.from_file(open(sample_image_url))
  end

  def baseline_snapshot
    Baseline.where(url_id: url.id).first.try(:snapshot)
  end

  def baseline_for_url?
    url.baseline.try(:snapshot) == self
  end

  def with_tempfile
    Dir.mktmpdir do |dir|
      random_name   = (0...8).map { (65 + rand(26)).chr }.join
      yield("#{dir}/#{random_name}.png")
    end
  end

  def take_snapshot!
    with_tempfile do |snapshot_file|
      opts = {
        address: url.address,
        outfile: snapshot_file,
        viewportSize: { width: url.viewport_width,
                        height: url.viewport_width * 2 }
      }
      Phantomjs.run(Rails.root.join('script', 'take-snapshot.js').to_s,
                    opts.to_json) { |line| puts line }
      self.external_image_id = upload_to_cloudinary(snapshot_file)
    end
  end

  def upload_to_cloudinary(file)
    Cloudinary::Uploader.upload(file)['public_id']
  end

  # @see http://jeffkreeftmeijer.com/2011/comparing-images-and-creating-image-diffs/
  def compare_with_previous!
    return unless previous = baseline_snapshot
    images = [
      to_chunky_png,
      previous.to_chunky_png,
    ]
    max_width  = [images.first.width, images.last.width].max
    max_height = [images.first.height, images.last.height].max
    output     = ChunkyPNG::Image.new(max_width, max_height, WHITE)

    diff = []

    min_width = [images.first.width, images.last.width].min
    images.first.height.times do |y|
      images.first.row(y).each_with_index do |pixel, x|
        if x < min_width && (pixel != images.last[x, y])
          score = Math.sqrt(
            (r(images.last[x, y]) - r(pixel))**2 +
            (g(images.last[x, y]) - g(pixel))**2 +
            (b(images.last[x, y]) - b(pixel))**2
          ) / Math.sqrt(MAX**2 * 3)

          output[x, y] = grayscale(MAX - (score * MAX).round)
          diff << score
        end
      end
    end

    self.diff_from_previous = ((diff.inject { |sum, value| sum + value } || 0) /
                               images.first.pixels.length) * 100
    with_tempfile do |file|
      output.save(file)
      self.diff_external_image_id = upload_to_cloudinary(file)
    end
    self.diffed_with_snapshot = previous
  end
end
