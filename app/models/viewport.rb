# A Viewport represents the height and width of the screen when capturing a
# Snapshot for a Url.
class Viewport < ActiveRecord::Base
  validates :width, presence: true

  belongs_to :project
  validates :project, presence: true

  # @return [String]
  def to_s
    [width, height].join('x')
  end

  # @return [Integer]
  def height
    if width < 960
      width * 2
    else
      (width * 0.75).round # 16:12
    end
  end
end
