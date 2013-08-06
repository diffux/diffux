class Url < ActiveRecord::Base
  attr_accessible :address, :viewport_width
  validates_presence_of :viewport_width, :address
  validates_format_of :address, :with => /https?:\/\/.+/
  validates_uniqueness_of :address

  has_many :snapshots
end
