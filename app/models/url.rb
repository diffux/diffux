# A Url represents a page that can have Snapshots taken on it.
class Url < ActiveRecord::Base
  validates_format_of   :address, with: %r[\Ahttps?://.+]

  belongs_to :project
  validates_presence_of :project

  has_many :snapshots

  default_scope { order(:address) }

  # @return [String]
  def to_s
    address
  end

  def title
    accepted_snapshot = snapshots.where('accepted_at is not null').first
    if accepted_snapshot.try(:title)
      accepted_snapshot.title
    else
      simplified_address
    end
  end

  # @return [Snapshot]
  def baseline(viewport)
    snapshots
      .order('accepted_at DESC')
      .where(viewport: viewport)
      .where('accepted_at IS NOT NULL')
      .first
  end

  def simplified_address
    address.gsub(%r[(?:\Ahttp://|/\Z)], '')
  end

  # Get the two latest snapshots
  #
  # @return [Hash] (at most) two snapshots grouped by viewport
  def last_snapshots_by_viewport
    project.viewports.reduce({}) do |hash, viewport|
      hash[viewport] = snapshots.where(viewport_id: viewport).first(2)
      hash
    end
  end
end
