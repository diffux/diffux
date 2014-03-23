# This subclass of `SnapshotComparisonImage` knows how to overlay the
# after-image on top of the before-image, and render the difference in a scaled
# magenta color.
class SnapshotComparisonImage::Overlayed < SnapshotComparisonImage
  MAGENTA = 3_543_565_055 # #b33682

  # @param y [Integer]
  # @param row [Diff::LCS:ContextChange]
  def render_unchanged_row(y, row)
    # Render translucent original pixels
    row.new_element.each_with_index do |pixel, x|
      @output.set_pixel(x, y, fade(pixel, BASE_ALPHA))
    end
  end

  # @param y [Integer]
  # @param row [Diff::LCS:ContextChange]
  def render_deleted_row(y, row)
    row.old_element.each_with_index do |pixel_before, x|
      render_faded_magenta_pixel(TRANSPARENT, pixel_before, x, y)
    end
  end

  # @param y [Integer]
  # @param row [Diff::LCS:ContextChange]
  def render_added_row(y, row)
    row.new_element.each_with_index do |pixel_after, x|
      render_faded_magenta_pixel(pixel_after, TRANSPARENT, x, y)
    end
  end

  # @param y [Integer]
  # @param row [Diff::LCS:ContextChange]
  def render_changed_row(y, row)
    row.old_element.zip(row.new_element).each_with_index do |pixels, x|
      pixel_before, pixel_after = pixels
      render_faded_magenta_pixel(
        pixel_after  || TRANSPARENT,
        pixel_before || TRANSPARENT,
        x, y)
    end
  end

  private

  # @param pixel_after [Integer]
  # @param pixel_before [Integer]
  # @param x [Integer]
  # @param y [Integer]
  def render_faded_magenta_pixel(pixel_after, pixel_before, x, y)
    score              = pixel_diff_score(pixel_after, pixel_before)
    output_color       = fade(MAGENTA, diff_alpha(score))
    @output.set_pixel(x, y, output_color)
  end
end
