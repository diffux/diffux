module ApplicationHelper
  # @param [String]
  # @return [String]
  def simplified_url(url)
    url.gsub(%r[(?:\Ahttp://|/\Z)], '')
  end
end
