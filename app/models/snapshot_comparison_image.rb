# This model represents a "comparison image". Basically it's just a wrapper
# around a ChunkyPNG image with some nice methods to make life easier in the
# world of diffs.
#
# This model is never persisted.
class SnapshotComparisonImage
  include ChunkyPNG::Color

  BASE_OPACITY    = 0.1
  BASE_ALPHA      = (255 * BASE_OPACITY).round
  BASE_DIFF_ALPHA = BASE_ALPHA * 2

  # @param width [Integer]
  # @param height [Integer]
  def initialize(width, height)
    @output = ChunkyPNG::Image.new(width, height)
  end

  # @param y [Integer]
  # @param row [Diff::LCS:ContextChange]
  def render_unchanged_row(y, row)
    row.new_element.each_with_index do |pixel, x|
      # Render the unchanged pixel as-is
      @output.set_pixel(x, y, pixel)
    end
  end

  # @param y [Integer]
  # @param row [Diff::LCS:ContextChange]
  def render_changed_row(y, row)
    # no default implementation
  end

  # @param y [Integer]
  # @param row [Diff::LCS:ContextChange]
  def render_added_row(y, row)
    # no default implementation
  end

  # @param y [Integer]
  # @param row [Diff::LCS:ContextChange]
  def render_deleted_row(y, row)
    # no default implementation
  end

  # @return [ChunkyPNG::Image] the png representation of this image.
  def to_png
    @output
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

  # @param diff_score [Float]
  # @return [Integer] a number between 0 and 255 that represents the alpha
  #   channel of of the difference
  def diff_alpha(diff_score)
    (BASE_DIFF_ALPHA + ((255 - BASE_DIFF_ALPHA) * diff_score)).round
  end

  protected

  # @param pixel [Integer]
  # @param overlay_color [Integer]
  # @param x [Integer]
  # @param y [Integer]
  def render_colored_pixel(pixel, overlay_color, x, y)
    output_color = compose_quick(fade(overlay_color, BASE_DIFF_ALPHA),
                                 pixel)
    @output.set_pixel(x, y, output_color)
  end
end
