class Sweep < ActiveRecord::Base
  belongs_to :project
  has_many   :snapshots
  validates_presence_of :title

  default_scope { order('created_at DESC') }

  def pending_snapshots
    snapshots.select(&:pending?)
  end

  def accepted_snapshots
    snapshots.select(&:accepted?)
  end

  def rejected_snapshots
    snapshots.select(&:rejected?)
  end

  def under_review_snapshots
    snapshots.select(&:under_review?)
  end
end
