# A Snapshot is a picture of a Url at a given Viewport.
class Snapshot < ActiveRecord::Base
  THUMB_CONVERT_OPTS =  '-gravity north -thumbnail 100x100^ -extent 100x100'

  belongs_to            :url
  belongs_to            :viewport
  belongs_to            :sweep
  belongs_to            :snapshot_diff
  validates_presence_of :url
  validates_presence_of :viewport
  has_attached_file     :image, styles:          { thumb: '' },
                                convert_options: { thumb: THUMB_CONVERT_OPTS }

  validates_attachment_content_type :image,
                                    content_type: /\Aimage\/.*\Z/

  # DEPRECATED: these fields will be removed in an upcoming commit
  belongs_to            :diffed_with_snapshot, class_name: Snapshot.name
  has_attached_file     :diff_image
  validates_attachment_content_type :diff_image,
                                    content_type: /\Aimage\/.*\Z/
  # END DEPRECATED

  default_scope { order('created_at DESC') }

  before_save  :auto_accept
  after_commit :take_snapshot, on: :create
  after_commit :compare_snapshot_if_needed, on: :update
  after_commit :refresh_sweep, on: [:create, :update]

  def diff?
    snapshot_diff_id? && snapshot_diff.before_snapshot != self
  end

  def accept
    self.accepted_at = Time.now
    self.rejected_at = nil
  end

  def accept!
    accept
    save!
  end

  def reject!
    self.rejected_at = Time.now
    self.accepted_at = nil
    save!
  end

  def pending?
    !image? || waiting_for_diff?
  end

  def accepted?
    accepted_at?
  end

  def rejected?
    rejected_at?
  end

  def under_review?
    !pending? && !accepted? && !rejected?
  end

  def compare?
    return false if accepted?
    baseline = url.baseline(viewport)
    return false unless baseline
    return false if baseline.created_at > created_at
    !diff?
  end

  def take_snapshot
    SnapshotterWorker.perform_async(id)
  end

  private

  def auto_accept
    return unless snapshot_diff
    return if snapshot_diff.before_snapshot == self
    self.accepted_at = Time.now if snapshot_diff.diff_in_percent == 0
  end

  def compare_snapshot_if_needed
    SnapshotComparerWorker.perform_async(id) if compare?
  end

  def refresh_sweep
    return unless sweep
    sweep.refresh!
  end

  def waiting_for_diff?
    baseline = url.baseline(viewport)
    image? &&
      !diff? &&
      baseline.present? &&
      baseline != self &&
      baseline.created_at < created_at
  end
end
