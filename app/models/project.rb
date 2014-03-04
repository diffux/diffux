class Project < ActiveRecord::Base
  validates_presence_of :name

  attr_accessor :viewport_widths
  attr_accessor :url_addresses

  has_many :urls
  has_many :viewports
  has_many :sweeps

  after_validation :save_viewport_widths
  after_validation :save_url_addresses

  # @return [String]
  def viewport_widths
    @viewport_widths ||= viewports.pluck(:width).join("\n")
  end

  # @return [String]
  def url_addresses
    @url_addresses ||= urls.pluck(:address).join("\n")
  end

  private

  # @param str [String]
  # @return [Array]
  def string_to_array(str)
    str.split(/\s+/).uniq.reject { |line| line.empty? }
  end

  def save_viewport_widths
    if viewport_widths
      old_widths = viewports.pluck(:width)
      new_widths = string_to_array(viewport_widths).map(&:to_i)

      (old_widths - new_widths).each do |width|
        viewports.where(width: width).destroy_all
      end

      (new_widths - old_widths).each do |width|
        viewports.new(width: width.to_i)
      end
    end
  end

  def save_url_addresses
    if url_addresses
      old_addresses = urls.pluck(:address)
      new_addresses = string_to_array(url_addresses)

      (old_addresses - new_addresses).each do |address|
        urls.where(address: address).destroy_all
      end

      (new_addresses - old_addresses).each do |address|
        urls.new(address: address)
      end
    end
  end
end
