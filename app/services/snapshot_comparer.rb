require 'oily_png'
require 'open-uri'

class SnapshotComparer
  include ChunkyPNG::Color

  def initialize(snapshot_after, snapshot_before)
    @snapshot_after  = snapshot_after
    @snapshot_before = snapshot_before
  end

  # @see http://jeffkreeftmeijer.com/2011/comparing-images-and-creating-image-diffs/
  def compare!
    image_after  = to_chunky_png(@snapshot_after)
    image_before = to_chunky_png(@snapshot_before)

    output = ChunkyPNG::Image.new([image_before.width, image_after.width].max,
                                  [image_before.height, image_after.height].max,
                                  WHITE)
    diff = 0
    min_width = [image_before.width, image_after.width].min
    image_before.height.times do |y|
      image_before.row(y).each_with_index do |pixel, x|
        if x < min_width && (pixel != image_after[x, y])
          score = Math.sqrt(
            (r(image_after[x, y]) - r(pixel))**2 +
            (g(image_after[x, y]) - g(pixel))**2 +
            (b(image_after[x, y]) - b(pixel))**2
          ) / Math.sqrt(MAX**2 * 3)

          output[x, y] = grayscale(MAX - (score * MAX).round)
          diff += score
        end
      end
    end

    result = {
      diff_in_percent: diff.to_f / image_before.pixels.length * 100
    }
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
