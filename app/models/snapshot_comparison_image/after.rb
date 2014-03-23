# This subclass of `SnapshotComparisonImage` knows how to draw the
# representation of the "after" image.
class SnapshotComparisonImage::After < SnapshotComparisonImage
  GREEN = 2_241_396_991 # #859900

  # @param y [Integer]
  # @param row [Diff::LCS:ContextChange]
  def render_changed_row(y, row)
    render_added_row(y, row)
  end

  # @param y [Integer]
  # @param row [Diff::LCS:ContextChange]
  def render_added_row(y, row)
    row.new_element.each_with_index do |pixel_after, x|
      render_colored_pixel(pixel_after, GREEN, x, y)
    end
  end
end
