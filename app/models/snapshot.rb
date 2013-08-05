require 'phantomjs'

class Snapshot < ActiveRecord::Base
  attr_accessible :external_image_id, :url
  belongs_to :url
  validates_presence_of :url, :external_image_id

  before_validation :take_snapshot!

  def image_name
    self.external_image_id + '.png'
  end

private

  def take_snapshot!
    Dir.mktmpdir do |dir|
      random_name   = (0...8).map{(65+rand(26)).chr}.join
      snapshot_file = "#{dir}/#{random_name}.png"
      Phantomjs.run(Rails.root.join('script', 'take-snapshot.js').to_s,
                  self.url.address, snapshot_file) { |line| puts line }
      uploaded_image = Cloudinary::Uploader.upload(snapshot_file)
      self.external_image_id = uploaded_image['public_id']
    end
  end
end
