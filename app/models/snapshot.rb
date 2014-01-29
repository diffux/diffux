class Snapshot < ActiveRecord::Base
  belongs_to :url
  belongs_to :diffed_with_snapshot, class_name: Snapshot.name
  validates_presence_of :url
  default_scope { order('created_at DESC') }

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

  def baseline_for_url?
    url.baseline.try(:snapshot) == self
  end
end
