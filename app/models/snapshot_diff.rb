# Models the difference between two snapshots
class SnapshotDiff < ActiveRecord::Base
  has_attached_file :image

  belongs_to :before_snapshot, class_name: 'Snapshot'
  has_one    :after_snapshot,  class_name: 'Snapshot'
  has_many   :snapshot_diff_clusters

  validates_attachment_content_type :image,
                                    content_type: /\Aimage\/.*\Z/

  validates :diff_in_percent, numericality: true
end
