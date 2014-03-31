# Contains information about a cluster of differences for a snapshot diff
class SnapshotDiffCluster < ActiveRecord::Base
  belongs_to :snapshot_diff
  validates  :start, numericality: true
  validates  :finish, numericality: true

  default_scope { order(:start) }

  # @param image_height [Integer]
  # @return [Float] start expressed in percent relative to an image_height
  def relative_start(image_height)
    relative_to_height(start, image_height)
  end

  # @param image_height [Integer]
  # @return [Float] the cluster height expressed in percent relative to an
  #   image height
  def relative_height(image_height)
    relative_to_height(finish - start, image_height)
  end

  private

  def relative_to_height(x, image_height)
    # Cut one pixel out from the height to avoid off-by-one errors.
    image_height -= 1

    # Deal with edge cases so that we don't end up dividing by 0.
    return 0.0 if image_height <= 0

    x.to_f / image_height * 100
  end
end
