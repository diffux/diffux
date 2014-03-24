require 'oily_png'
require 'open-uri'
require 'diff-lcs'

# This class is responsible for comparing two Snapshots and generating a diff.
class SnapshotComparer
  def initialize(snapshot_after, snapshot_before)
    @snapshot_after  = snapshot_after
    @snapshot_before = snapshot_before
  end

  # @return [Hash]
  def compare!
    png_after  = to_chunky_png(@snapshot_after)
    png_before = to_chunky_png(@snapshot_before)
    max_width  = [png_after.width, png_before.width].max

    # sdiff will use traverse_balanced, which reports changes, whereas diff
    # will use traverse_sequences, which reports insertions or deletions.
    sdiff          = Diff::LCS.sdiff(to_array_of_arrays(png_before),
                                     to_array_of_arrays(png_after))
    cluster_finder = DiffClusterFinder.new(sdiff.size)

    all_comparisons = [
      SnapshotComparisonImage::Before.new(max_width, sdiff.size),
      SnapshotComparisonImage::Overlayed.new(max_width, sdiff.size),
      SnapshotComparisonImage::After.new(max_width, sdiff.size),
    ]

    sdiff.each_with_index do |row, y|
      # each row is a Diff::LCS::ContextChange instance
      if row.unchanged?
        all_comparisons.each { |image| image.render_unchanged_row(y, row) }
      else
        # This row has changed in some way, so we want to render the visual
        # difference.
        cluster_finder.row_is_different(y)
        if row.deleting?
          all_comparisons.each { |image| image.render_deleted_row(y, row) }
        elsif row.adding?
          all_comparisons.each { |image| image.render_added_row(y, row) }
        else # changing?
          all_comparisons.each { |image| image.render_changed_row(y, row) }
        end
      end
    end

    percent_changed = cluster_finder.percent_of_rows_different
    sprite = stitch_pngs(all_comparisons) if percent_changed > 0
    {
      diff_in_percent: percent_changed,
      diff_image:      sprite,
      diff_clusters:   cluster_finder.clusters,
    }
  end

  private

  # Stiches together an ordered collection of `SnapshotComparisonImage`s into
  # one single `ChunkyPNG::Image`.
  #
  # @param all_comparisons [Array<SnapshotComparisonImage>]
  # @return [ChunkyPNG::Image] a single image containing all comparison images
  def stitch_pngs(all_comparisons)
    pngs   = all_comparisons.map(&:to_png)
    width  = pngs.reduce(0) { |a, e| a + e.width }
    offset = 0
    ChunkyPNG::Image.new(width, pngs.first.height).tap do |sprite|
      pngs.each do |png|
        sprite.replace!(png, offset, 0)
        offset += png.width
      end
    end
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
