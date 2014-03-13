# A Url represents a page that can have Snapshots taken on it.
class Url < ActiveRecord::Base
  validates :address, format: { with: %r[\Ahttps?://.+] }

  belongs_to :project, counter_cache: true
  validates :project, presence: true

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
end
