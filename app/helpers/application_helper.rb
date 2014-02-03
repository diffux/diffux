module ApplicationHelper
  # @param [String]
  # @return [String]
  def simplified_url(url)
    url.gsub(%r[\Ahttp://], '')
  end
end
