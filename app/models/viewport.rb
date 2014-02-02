class Viewport < ActiveRecord::Base
  validates_presence_of :width

  belongs_to :project
  validates_presence_of :project

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
