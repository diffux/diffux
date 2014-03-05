# Helpers for application-wide things.
module ApplicationHelper
  # @param url [String]
  # @return [String]
  def simplified_url(url)
    url.gsub(%r[(?:\Ahttp://|/\Z)], '')
  end

  # @param text [String]
  # @param path [String]
  # @return [String] a prepared <li> element with an <a> tag inside
  def menu_item(text, path)
    is_active = request.fullpath.starts_with? path
    content_tag :li, link_to(text, path), class: ('active' if is_active)
  end
end
