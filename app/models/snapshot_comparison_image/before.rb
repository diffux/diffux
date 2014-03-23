# This subclass of `SnapshotComparisonImage` knows how to draw the
# representation of the "before" image.
class SnapshotComparisonImage::Before < SnapshotComparisonImage
  RED = 3_694_276_607 # #dc322f

  # @param y [Integer]
  # @param row [Diff::LCS:ContextChange]
  def render_changed_row(y, row)
    render_deleted_row(y, row)
  end

  # @param y [Integer]
  # @param row [Diff::LCS:ContextChange]
  def render_deleted_row(y, row)
    row.old_element.each_with_index do |pixel_before, x|
      render_colored_pixel(pixel_before, RED, x, y)
    end
  end
end
