# A Viewport represents the height and width of the screen when capturing a
# Snapshot for a Url.
class Viewport < ActiveRecord::Base
  validates :width, presence: true

  belongs_to :project
  validates :project, presence: true

  # @return [String] a representation of the Viewport instance in the format of
  #   {width}x{height}.
  def to_s
    [width, height].join('x')
  end

  # @return [Integer] dynamically calculated height based on the width. For
  #   narrow widths, this will be tall, as if in portrait mode on a phone. For
  #   wider widths, this will be shorter, as if in landscape orientation on a
  #   laptop or desktop monitor.
  def height
    if width < 960
      width * 2
    else
      (width * 0.75).round # 16:12
    end
  end
end
