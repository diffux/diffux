module SnapshotComparisonImage
  # This model represents a "comparison image". Basically it's just a wrapper
  # around a ChunkyPNG image with some nice methods to make life easier in the
  # world of diffs.
  #
  # This model is never persisted.
  class Base
    include ChunkyPNG::Color

    BASE_OPACITY    = 0.1
    BASE_ALPHA      = (255 * BASE_OPACITY).round
    BASE_DIFF_ALPHA = BASE_ALPHA * 2

    MAGENTA = ChunkyPNG::Color.from_hex '#b33682'
    RED     = ChunkyPNG::Color.from_hex '#dc322f'
    GREEN   = ChunkyPNG::Color.from_hex '#859900'

    # @param offset [Integer] the x-offset that this comparison image should
    #   use when rendering on the canvas image.
    # @param canvas [ChunkyPNG::Image] The canvas image to render pixels on.
    def initialize(offset, canvas)
      @offset = offset
      @canvas = canvas
    end

    # @param y [Integer]
    # @param row [Diff::LCS:ContextChange]
    def render_row(y, row)
      if row.unchanged?
        render_unchanged_row(y, row)
      elsif row.deleting?
        render_deleted_row(y, row)
      elsif row.adding?
        render_added_row(y, row)
      else # changing?
        render_changed_row(y, row)
      end
    end

    # @param y [Integer]
    # @param row [Diff::LCS:ContextChange]
    def render_unchanged_row(y, row)
      row.new_element.each_with_index do |pixel, x|
        # Render the unchanged pixel as-is
        render_pixel(x, y, pixel)
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

    # @param pixel_after [Integer]
    # @param pixel_before [Integer]
    # @return [Float] number between 0 and 1 where 1 is completely different
    #   and 0 is no difference
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

    # Renders a pixel on the specified x and y position. Uses the offset that
    # the comparison image has been configured with.
    #
    # @param x [Integer]
    # @param y [Integer]
    # @param pixel [Integer]
    def render_pixel(x, y, pixel)
      @canvas.set_pixel(x + @offset, y, pixel)
    end
  end
end
