# Contains information about a cluster of differences for a snapshot diff
class SnapshotDiffCluster < ActiveRecord::Base
  belongs_to                :snapshot_diff
  validates_numericality_of :start,
                            :finish

  default_scope { order(:start) }
end
