class Url < ActiveRecord::Base
  validates_presence_of :viewport_width,
                        :address

  validates_format_of   :address, with: %r[\Ahttps?://.+]

  has_many :snapshots

  default_scope { order(:address) }

  def baseline
    snapshots.order('accepted_at DESC').where('accepted_at IS NOT NULL').first
  end
end
