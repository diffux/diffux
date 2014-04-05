# Models the difference between two snapshots
class SnapshotDiff < ActiveRecord::Base
  has_attached_file :image

  belongs_to :before_snapshot, class_name: 'Snapshot'
  has_one    :after_snapshot,  class_name: 'Snapshot'
  has_many   :snapshot_diff_clusters, dependent: :destroy

  validates_attachment_content_type :image,
                                    content_type: /\Aimage\/.*\Z/

  validates :diff_in_percent, numericality: true

  # @return [Boolean] true if this snapshot diff has been saved as a sprite,
  #   i.e. has a before, diff, and after image all combined into one.
  def sprite?
    # The `image_width` property was added at the same time as snapshot diffs
    # became sprites, so we can use that to infer the `sprite?` status.
    image_width?
  end
end
