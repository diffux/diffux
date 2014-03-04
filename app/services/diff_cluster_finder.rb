require 'set'
# This class finds clusters in a diff. A cluster is defined as rows that are
# different, and are closer than DIFF_ROW_THRESHOLD pixels to its neighboring
# diff row.
class DiffClusterFinder
  MAXIMUM_ADJACENCY_GAP = 20

  # @param number_of_rows [Numeric]
  def initialize(number_of_rows)
    @number_of_rows = number_of_rows
    @rows_with_diff = SortedSet.new
  end

  # Tell the DiffClusterFinder about a row that is different.
  #
  # @param row [Numeric]
  def row_is_different(row)
    @rows_with_diff.add row
  end

  # Calculate clusters from diff-rows that are close to each other.
  #
  # @return [Array] a list of clusters modeled as hashes:
  #   `{ start: x, finish: y }`
  def clusters
    results = []
    @rows_with_diff.each do |row|
      current = results.last
      if !current || current[:finish] + MAXIMUM_ADJACENCY_GAP < row
        results << {
          start:  row,
          finish: row,
        }
      else
        current[:finish] = row
      end
    end
    results
  end
end
