class Url < ActiveRecord::Base
  attr_accessible :address
  validates_format_of :address, :with => /https?:\/\/.+/
  has_many :snapshots
end
