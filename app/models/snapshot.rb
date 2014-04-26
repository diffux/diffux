# A Snapshot is a picture of a Url at a given Viewport.
class Snapshot < ActiveRecord::Base
  THUMB_CONVERT_OPTS =  '-gravity north -thumbnail 100x100^ -extent 100x100'

  belongs_to :url, counter_cache: true
  belongs_to :viewport
  belongs_to :sweep
  belongs_to :snapshot_diff, dependent: :destroy
  belongs_to :compared_with, class_name: 'Snapshot'
  validates  :url,      presence: true
  validates  :viewport, presence: true
  has_attached_file     :image, styles:          { thumb: '' },
                                convert_options: { thumb: THUMB_CONVERT_OPTS }

  validates_attachment_content_type :image,
                                    content_type: /\Aimage\/.*\Z/

  default_scope { order('created_at DESC') }

  before_save  :auto_accept
  after_commit :take_snapshot, on: :create
  after_commit :compare_snapshot_if_needed, on: :update
  after_commit :refresh_sweep, on: [:create, :update]

  def diff?
    snapshot_diff_id? && before_snapshot != self
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
    return false unless image_file_name
    return false if accepted?
    compare_with = compared_with || url.baseline(viewport)
    return false unless compare_with
    return false if compare_with.created_at > created_at
    !diff?
  end

  def take_snapshot
    SnapshotterWorker.perform_async(id)
  end

  # @return [Snapshot]
  def before_snapshot
    return unless snapshot_diff
    snapshot_diff.before_snapshot
  end

  private

  def auto_accept
    return unless snapshot_diff
    return if before_snapshot == self
    return if rejected?
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
    compare_with = compared_with || url.baseline(viewport)
    image? &&
      !diff? &&
      compare_with.present? &&
      compare_with != self &&
      compare_with.created_at < created_at
  end
end
