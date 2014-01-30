class Snapshot < ActiveRecord::Base
  belongs_to :url
  belongs_to :diffed_with_snapshot, class_name: Snapshot.name
  validates_presence_of :url
  default_scope { order('created_at DESC') }

  before_save :auto_accept

  def image_name
    external_image_id + '.png'
  end

  def diff_image_name
    diff_external_image_id + '.png'
  end

  def diff?
    !!diffed_with_snapshot
  end

  def sample_image_url
    Cloudinary::Utils.cloudinary_url(image_name)
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

  def accepted?
    accepted_at?
  end

  def rejected?
    rejected_at?
  end

  private

  def auto_accept
    self.accepted_at = Time.now if diff_from_previous == 0
  end
end
