class Url < ActiveRecord::Base
  attr_accessible :address, :viewport_width, :name, :active
  validates_presence_of :viewport_width, :address, :name
  validates_format_of :address, :with => /https?:\/\/.+/
  validates_uniqueness_of :address

  has_many :snapshots
  has_one  :baseline
  default_scope order(:name)
end
