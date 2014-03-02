# Models the difference between two snapshots
class SnapshotDiff < ActiveRecord::Base
  has_attached_file :image

  belongs_to :before_snapshot, class_name: 'Snapshot'
  has_one    :after_snapshot,  class_name: 'Snapshot'

  validates_attachment_content_type :image,
                                    :content_type => /\Aimage\/.*\Z/
  validates_numericality_of :diff_in_percent
end
