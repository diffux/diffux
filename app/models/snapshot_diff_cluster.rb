# Contains information about a cluster of differences for a snapshot diff
class SnapshotDiffCluster < ActiveRecord::Base
  belongs_to :snapshot_diff
  validates  :start, numericality: true
  validates  :finish, numericality: true

  default_scope { order(:start) }

  # @param image_height [Integer]
  # @return [Float] start expressed in percent relative to an image_height
  def relative_start(image_height)
    return 0.0 if image_height == 0
    start.to_f / image_height * 100
  end

  # @param image_height [Integer]
  # @return [Float] the cluster height expressed in percent relative to an
  #   image height
  def relative_height(image_height)
    return 0.0 if image_height == 0
    (finish + 1 - start).to_f / image_height * 100
  end
end
