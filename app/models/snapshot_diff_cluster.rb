# Contains information about a cluster of differences for a snapshot diff
class SnapshotDiffCluster < ActiveRecord::Base
  belongs_to                :snapshot_diff
  validates_numericality_of :start,
                            :finish

  default_scope { order(:start) }

  # @return [Float] start expressed in percent relative to an image_height
  def relative_start(image_height)
    start.to_f / image_height * 100
  end

  # @return [Float] the cluster height expressed in percent relative to an image
  #   height
  def relative_height(image_height)
    (finish + 1 - start).to_f / image_height * 100
  end
end
