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
    png_after  = to_chunky_png(@snapshot_after)
    png_before = to_chunky_png(@snapshot_before)

    output = ChunkyPNG::Image.new([png_before.width, png_after.width].max,
                                  [png_before.height, png_after.height].max,
                                  WHITE)
    diff = 0
    min_width = [png_before.width, png_after.width].min
    png_before.height.times do |y|
      png_before.row(y).each_with_index do |pixel_before, x|
        if x < min_width && (pixel_before != png_after[x, y])
          score        = pixel_diff_score(png_after[x, y], pixel_before)
          output[x, y] = grayscale(MAX - (score * MAX).round)
          diff        += score
        end
      end
    end

    result = {
      diff_in_percent: diff.to_f / png_before.pixels.length * 100
    }
    FileUtil.with_tempfile do |file|
      output.save(file)
      result[:external_image_id] = FileUtil.upload_to_cloudinary(file)
    end
    result
  end

private

  def pixel_diff_score(pixel_after, pixel_before)
    Math.sqrt(
      (r(pixel_after) - r(pixel_before))**2 +
      (g(pixel_after) - g(pixel_before))**2 +
      (b(pixel_after) - b(pixel_before))**2
    ) / Math.sqrt(MAX**2 * 3)
  end

  def to_chunky_png(snapshot)
    ChunkyPNG::Image.from_file(open(snapshot.sample_image_url))
  end
end
