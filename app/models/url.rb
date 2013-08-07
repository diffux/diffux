class Url < ActiveRecord::Base
  attr_accessible :address, :viewport_width, :name
  validates_presence_of :viewport_width, :address, :name
  validates_format_of :address, :with => /https?:\/\/.+/
  validates_uniqueness_of :address

  has_many :snapshots
  default_scope order(:name)
end
