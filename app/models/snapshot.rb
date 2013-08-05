require 'phantomjs'
require 'chunky_png'
require 'open-uri'

class Snapshot < ActiveRecord::Base
  include ChunkyPNG::Color

  attr_accessible :external_image_id, :url
  belongs_to :url
  validates_presence_of :url, :external_image_id
  default_scope order('created_at DESC')

  before_validation :take_snapshot!

  def image_name
    self.external_image_id + '.png'
  end

  def sample_image_url
    #TODO: how do I get access to helper methods here? (`cl_image_path`)

    # Use max 1500 high images, to speed up diff
    "http://res.cloudinary.com/diffux/image/upload/c_fit,h_1500/v1375678803/#{image_name}"
  end

  def to_chunky_png
    ChunkyPNG::Image.from_file(open(self.sample_image_url))
  end

  def previous_snapshot
    url.snapshots.where('created_at < ?', self.created_at).first
  end

  def with_tempfile
    Dir.mktmpdir do |dir|
      random_name   = (0...8).map{(65+rand(26)).chr}.join
      yield("#{dir}/#{random_name}.png")
    end
  end

  def take_snapshot!
    with_tempfile do |snapshot_file|
      Phantomjs.run(Rails.root.join('script', 'take-snapshot.js').to_s,
                  self.url.address, snapshot_file) { |line| puts line }
      self.external_image_id = upload_to_cloudinary(snapshot_file)
    end
  end

  def upload_to_cloudinary(file)
    Cloudinary::Uploader.upload(file)['public_id']
  end

  def compare_with_previous!
    unless previous_snapshot
      return
    end

    # Mostly copied from
    # http://jeffkreeftmeijer.com/2011/comparing-images-and-creating-image-diffs/
    images = [
      self.to_chunky_png,
      previous_snapshot.to_chunky_png
    ]
    max_width = [images.first.width, images.last.width].max
    max_height = [images.first.height, images.last.height].max
    output = ChunkyPNG::Image.new(max_width, max_height, WHITE)

    diff = []

    images.first.height.times do |y|
      images.first.row(y).each_with_index do |pixel, x|
        unless pixel == images.last[x,y]
          score = Math.sqrt(
            (r(images.last[x,y]) - r(pixel)) ** 2 +
            (g(images.last[x,y]) - g(pixel)) ** 2 +
            (b(images.last[x,y]) - b(pixel)) ** 2
          ) / Math.sqrt(MAX ** 2 * 3)

          output[x,y] = grayscale(MAX - (score * MAX).round)
          diff << score
        end
      end
    end

    self.diff_from_previous = (diff.inject {|sum, value| sum + value} /
                               images.first.pixels.length) * 100
    with_tempfile do |file|
      output.save(file)
      self.diff_external_image_id = self.upload_to_cloudinary(file)
    end
  end
end
