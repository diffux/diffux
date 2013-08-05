require 'phantomjs'

class Snapshot < ActiveRecord::Base
  attr_accessible :image_url
  belongs_to :url
  validates_presence_of :url, :image_url

  before_save :take_snapshot

  def take_snapshot
    Dir.mktmpdir do |dir|
      random_name   = (0...8).map{(65+rand(26)).chr}.join
      snapshot_file = "#{dir}/#{random_name}.png"

      Phantomjs.run(Rails.root.join('script', 'take-snapshot.js').to_s,
                  'http://www.google.com', snapshot_file)

      uploaded_image = Cloudinary::Uploader.upload(snapshot_file)
      self.image_url = uploaded_image[:url]
    end
  end
end
