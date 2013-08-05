class Snapshot < ActiveRecord::Base
  attr_accessible :url

  validates_format_of :url, :with => /https?:\/\/.+/
end
