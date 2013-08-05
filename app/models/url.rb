class Url < ActiveRecord::Base
  attr_accessible :address
  validates_format_of :address, :with => /https?:\/\/.+/
  validates_uniqueness_of :address

  has_many :snapshots
end
