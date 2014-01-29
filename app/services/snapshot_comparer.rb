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
    image1 = to_chunky_png(@snapshot1)
    image2 = to_chunky_png(@snapshot2)

    output = ChunkyPNG::Image.new([image1.width, image2.width].max,
                                  [image1.height, image2.height].max,
                                  WHITE)
    diff = 0
    min_width = [image1.width, image2.width].min
    image1.height.times do |y|
      image1.row(y).each_with_index do |pixel, x|
        if x < min_width && (pixel != image2[x, y])
          score = Math.sqrt(
            (r(image2[x, y]) - r(pixel))**2 +
            (g(image2[x, y]) - g(pixel))**2 +
            (b(image2[x, y]) - b(pixel))**2
          ) / Math.sqrt(MAX**2 * 3)

          output[x, y] = grayscale(MAX - (score * MAX).round)
          diff += score
        end
      end
    end

    result = {
      diff_in_percent: diff.to_f / image1.pixels.length * 100
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
