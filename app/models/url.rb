class Url < ActiveRecord::Base
  validates_presence_of :viewport_width,
                        :address,
                        :name

  validates_format_of   :address, with: %r[\Ahttps?://.+]

  has_many :snapshots

  default_scope { order(:name) }

  def to_param
    [id, slugify(name)].join('-')
  end

  def baseline
    snapshots.order('accepted_at DESC').where('accepted_at IS NOT NULL').first
  end

  private

  # @param [String] string to slugify
  # @return [String] slugified version of str
  def slugify(str)
    str.gsub(/['’]/, '').parameterize
  end
end
