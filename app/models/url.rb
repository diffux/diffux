class Url < ActiveRecord::Base
  validates_presence_of :viewport_width,
                        :address,
                        :name

  validates_format_of     :address, with: %r[https?://.+]
  validates_uniqueness_of :address

  has_many :snapshots
  has_one  :baseline

  default_scope { order(:name) }

  def to_param
    [id, slugify(name)].join('-')
  end

  private

  # @param [String] string to slugify
  # @return [String] slugified version of str
  def slugify(str)
    str.gsub(/['’]/, '').parameterize
  end
end
