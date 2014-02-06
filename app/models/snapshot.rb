class Snapshot < ActiveRecord::Base
  THUMB_CONVERT_OPTS =  '-gravity north -thumbnail 100x100^ -extent 100x100'

  belongs_to            :url
  belongs_to            :viewport
  belongs_to            :diffed_with_snapshot, class_name: Snapshot.name
  validates_presence_of :url
  validates_presence_of :viewport
  has_attached_file     :diff_image
  has_attached_file     :image, styles:  { thumb: '' },
                        convert_options: { thumb: THUMB_CONVERT_OPTS }

  validates_attachment_content_type :image,
                                    :content_type => /\Aimage\/.*\Z/
  validates_attachment_content_type :diff_image,
                                    :content_type => /\Aimage\/.*\Z/

  default_scope { order('created_at DESC') }

  before_save :auto_accept

  def diff?
    !!diffed_with_snapshot
  end

  def accept!
    self.accepted_at = Time.now
    self.rejected_at = nil
    save!
  end

  def reject!
    self.rejected_at = Time.now
    self.accepted_at = nil
    save!
  end

  def pending?
    !image?
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

  private

  def auto_accept
    self.accepted_at = Time.now if diff_from_previous == 0
  end
end
