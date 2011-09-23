module SpriteEdit
class SpritePart < Chingu::GameObject
  trait :bounding_box, debug: DEBUG
  attr_reader :part, :frame, :rx, :ry
  def initialize options = {}
    raise 'SpritePart created without :part option' unless options.has_key?(:part)
    raise 'SpritePart created without :rx or :ry' unless options.has_key?(:rx) || options.has_key?(:ry)
    raise 'SpritePart created without :frame' unless options.has_key?(:frame)
    @part = options.delete :part
    @rx, @ry = options.delete(:rx), options.delete(:ry)
    @frame = options.delete :frame
    super options.merge(rotation_center: :top_left)
  end
  
  def setup
    @anim = $window.current_scope.parts[@part[0]]
    @real_x, @real_y = @x, @y
  end
  
  def rx= value
    @rx = value
    @x  = @rx * @factor_x + @real_x
  end
  
  def ry= value
    @ry = value
    @y  = @ry * @factor_y + @real_y
  end
  
  def index
    @part[1]
  end
  
  def index= new
    @part[1] = new
  end
  
  def next
    self.index = (index + 1)%@anim.size
  end
  
  def last
    self.index = (index - 1)%@anim.size
  end
  
  def draw
    #adapted from lib/chingu/traits/sprite.rb
    #TODO: use draw_relative, allow use of angle and color
    @image.draw_rot @real_x+(@rx*@factor_x), @real_y+(@ry*@factor_y), @zorder, @angle, @center_x, @center_y, @factor_x, @factor_y, @color, @mode
  end
  
  def inspect
    "#<#{part[0]}:#{part[1]}(#{part[2]}) @ #{rx}/#{ry} in #{frame[0]}:#{frame[1]}>"
  end
end
end
