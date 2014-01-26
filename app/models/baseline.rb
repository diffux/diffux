class Baseline < ActiveRecord::Base
  belongs_to :url
  belongs_to :snapshot

  validates_uniqueness_of :url_id,
                          :snapshot_id
end
