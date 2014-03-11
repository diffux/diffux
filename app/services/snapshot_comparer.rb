require 'oily_png'
require 'open-uri'
require 'diff-lcs'

# This class is responsible for comparing two Snapshots and generating a diff.
class SnapshotComparer
  include ChunkyPNG::Color

  BASE_OPACITY    = 0.1
  BASE_ALPHA      = (255 * BASE_OPACITY).round
  BASE_DIFF_ALPHA = BASE_ALPHA * 2

  # Colors from Solarized
  # http://ethanschoonover.com/solarized
  RED     = 2241396991 # #dc322f
  GREEN   = 3694276607 # #859900
  MAGENTA = 3543565055 # #b33682

  def initialize(snapshot_after, snapshot_before)
    @snapshot_after  = snapshot_after
    @snapshot_before = snapshot_before
  end

  # @return [Hash]
  def compare!
    png_after         = to_chunky_png(@snapshot_after)
    png_before        = to_chunky_png(@snapshot_before)
    max_width         = [png_after.width, png_before.width].max
    max_height        = [png_after.height, png_before.height].max
    cluster_finder    = DiffClusterFinder.new(max_height)
    @total_diff_score = 0

    # sdiff will use traverse_balanced, which reports changes, whereas diff
    # will use traverse_sequences, which reports insertions or deletions.
    sdiff  = Diff::LCS.sdiff(to_array_of_arrays(png_before),
                             to_array_of_arrays(png_after))

    @output = ChunkyPNG::Image.new(max_width, sdiff.size)

    sdiff.each_with_index do |row, y|
      # each row is a Diff::LCS::ContextChange instance
      if row.unchanged?
        # This row has not changed, so we want to render a faded version of
        # the image to give the reviewer visual context.
        row.new_element.each_with_index do |pixel, x|
          @output.set_pixel(x, y, fade(pixel, BASE_ALPHA))
        end
      else
        # This row has changed in some way, so we want to render the visual
        # difference.
        cluster_finder.row_is_different(y)

        if row.deleting?
          row.old_element.each_with_index do |pixel_before, x|
            render_pixel(x, y, nil, pixel_before)
          end
        elsif row.adding?
          row.new_element.each_with_index do |pixel_after, x|
            render_pixel(x, y, pixel_after, nil)
          end
        else # changing?
          row.old_element.zip(row.new_element).each_with_index do |pixels, x|
            pixel_before, pixel_after = pixels
            render_pixel(x, y, pixel_after, pixel_before)
          end
        end
      end
    end

    {
      diff_in_percent: @total_diff_score.to_f / (max_width * max_height) * 100,
      diff_image:      (@output if @total_diff_score > 0),
      diff_clusters:   cluster_finder.clusters,
    }
  end

  private

  # @param x [Integer] the x-coordinate of the output image to render this
  #   pixel
  # @param y [Integer] the y-coordinate of the output image to render this
  #   pixel
  # @param pixel_after [Integer, nil] the color of the pixel as represented in
  #   the after image. If nil, will render pixel_before as-is, in full opacity
  #   with a translucent color overlay.
  # @param pixel_before [Integer, nil] the color of the pixel as represented in
  #   the before image. If nil, will render pixel_after as-is, in full opacity
  #   with a translucent color overlay.
  def render_pixel(x, y, pixel_after, pixel_before)
    if pixel_after.nil? || pixel_before.nil?
      # This pixel was either added (i.e not represented in the before image)
      # or deleted (i.e. not represented in the after image).  So, we want to
      # render it at full opacity and with a translucent color overlay.
      @total_diff_score += 1
      # TODO: For some reason the pixel_after and pixel_before are flipped. I
      # don't think this is actually impacting anything right now, but it
      # probably wouldn't be a bad idea to get to the bottom of it.
      overlay_color      = pixel_after.nil? ? GREEN : RED
      output_color       = compose_quick(fade(overlay_color, BASE_DIFF_ALPHA),
                                         pixel_after || pixel_before)
    elsif pixel_after == pixel_before
      # This pixel is in a row that has changed, but is identical, so we render
      # the same faded pixel as we do if the entire row has not changed, but
      # with a translucent magenta overlay.
      output_color       = compose_quick(fade(MAGENTA, BASE_ALPHA),
                                         fade(pixel_after, BASE_ALPHA))
    else
      # This pixel is changed, so we render the visual difference as a
      # function of the alpha channel.
      score              = pixel_diff_score(pixel_after, pixel_before)
      @total_diff_score += score
      output_color       = fade(MAGENTA, diff_alpha(score))
    end

    @output.set_pixel(x, y, output_color)
  end

  # @param diff_score [Float]
  # @return [Integer] a number between 0 and 255 that represents the alpha
  #   channel of of the difference
  def diff_alpha(diff_score)
    (BASE_DIFF_ALPHA + ((255 - BASE_DIFF_ALPHA) * diff_score)).round
  end

  # @param pixel_after [Integer]
  # @param pixel_before [Integer]
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

  # @param snapshot [Snapshot]
  # @return [ChunkyPNG::Image]
  def to_chunky_png(snapshot)
    case snapshot.image.options[:storage]
    when :s3
      ChunkyPNG::Image.from_io(open(snapshot.image.url))
    when :filesystem
      ChunkyPNG::Image.from_file(snapshot.image.path)
    end
  end

  # @param [ChunkyPNG::Image]
  # @return [Array<Array<Integer>>]
  def to_array_of_arrays(chunky_png)
    array_of_arrays = []
    chunky_png.height.times do |y|
      array_of_arrays << chunky_png.row(y)
    end
    array_of_arrays
  end
end
