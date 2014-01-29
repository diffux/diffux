require 'oily_png'
require 'open-uri'

class SnapshotComparer
  include ChunkyPNG::Color

  def initialize(snapshot1, snapshot2)
    @snapshot1 = snapshot1
    @snapshot2 = snapshot2
  end

  # @see http://jeffkreeftmeijer.com/2011/comparing-images-and-creating-image-diffs/
  def compare!
    images = [
      to_chunky_png(@snapshot1),
      to_chunky_png(@snapshot2),
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

    result = {}
    result[:diff_in_percent] = ((diff.inject { |sum, value| sum + value } || 0) /
                               images.first.pixels.length) * 100
    FileUtil.with_tempfile do |file|
      output.save(file)
      result[:external_image_id] = FileUtil.upload_to_cloudinary(file)
    end
    result
  end

private

  def to_chunky_png(snapshot)
    ChunkyPNG::Image.from_file(open(snapshot.sample_image_url))
  end
end
