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

  # @return [Snapshot]
  def baseline(viewport)
    snapshots
      .order('accepted_at DESC')
      .where(viewport: viewport)
      .where('accepted_at IS NOT NULL')
      .first
  end
end
