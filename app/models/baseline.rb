class Baseline < ActiveRecord::Base
  attr_accessible :url_id, :snapshot_id

  belongs_to :url
  belongs_to :snapshot

  validates_uniqueness_of :url_id,
                          :snapshot_id

end
