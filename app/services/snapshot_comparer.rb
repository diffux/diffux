require 'oily_png'
require 'open-uri'

class SnapshotComparer
  include ChunkyPNG::Color

  def initialize(snapshot_after, snapshot_before)
    @snapshot_after  = snapshot_after
    @snapshot_before = snapshot_before
  end

  # @return [Hash]
  # @see http://jeffkreeftmeijer.com/2011/comparing-images-and-creating-image-diffs/
  def compare!
    png_after    = to_chunky_png(@snapshot_after)
    png_before   = to_chunky_png(@snapshot_before)

    max_width    = [png_after.width, png_before.width].max
    max_height   = [png_after.height, png_before.height].max
    output       = ChunkyPNG::Image.new(max_width, max_height)

    diff            = 0
    base_opacity    = 0.1
    base_alpha      = (255 * base_opacity).round
    base_diff_alpha = base_alpha * 2

    max_height.times do |y|
      max_width.times do |x|
        pixel_after  = get_pixel(png_after, x, y)
        pixel_before = get_pixel(png_before, x, y)

        base_pixel   = fade(pixel_before, base_alpha)
        if pixel_after != pixel_before
          score        = pixel_diff_score(pixel_after, pixel_before)
          diff        += score

          diff_alpha   = (base_diff_alpha + ((255 - base_diff_alpha) * score)).round
          diff_color   = ChunkyPNG::Color.rgba(255, 0, 100, diff_alpha)
          output.set_pixel(x, y, diff_color)
        else
          output.set_pixel(x, y, base_pixel)
        end
      end
    end

    {
      diff_in_percent: diff.to_f / png_before.pixels.length * 100,
      diff_image:      (output if diff > 0),
    }
  end

  private

  def get_pixel(image, x, y)
    if y < image.height && x < image.width
      image.get_pixel(x, y)
    else
      ChunkyPNG::Color::TRANSPARENT
    end
  end

  # @return [Float] number between 0 and 1 where 1 is completely different and
  #   0 is no difference
  def pixel_diff_score(pixel_after, pixel_before)
    Math.sqrt(
      (r(pixel_after) - r(pixel_before))**2 +
      (g(pixel_after) - g(pixel_before))**2 +
      (b(pixel_after) - b(pixel_before))**2 +
      (a(pixel_after) - a(pixel_before))**2
    ) / Math.sqrt(ChunkyPNG::Color::MAX**2 * 4)
  end

  def to_chunky_png(snapshot)
    case snapshot.image.options[:storage]
    when :s3
      ChunkyPNG::Image.from_io(open(snapshot.image.url))
    when :filesystem
      ChunkyPNG::Image.from_file(snapshot.image.path)
    end
  end
end
