class Url < ActiveRecord::Base
  validates_presence_of :viewport_width, :address
  validates_format_of :address, :with => /https?:\/\/.+/
  validates_uniqueness_of :address

  has_many :snapshots
  default_scope order(:address)
end
