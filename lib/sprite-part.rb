module SpriteEdit
class SpritePart < Chingu::GameObject
  trait :bounding_box
  attr_reader :part, :rx, :ry, :frame
  def initialize options = {}
    raise 'SpritePart created without :part option' unless options.has_key?(:part)
    raise 'SpritePart created without :rx or :ry' unless options.has_key?(:rx) || options.has_key?(:ry)
    raise 'SpritePart created without :frame' unless options.has_key?(:frame)
    @part = options.delete :part
    @rx, @ry = options.delete(:rx), options.delete(:ry)
    @frame = options.delete :frame
    super(options)
  end
  
  def draw
    #adapted from lib/chingu/traits/sprite.rb
    @image.draw_rot @x+@rx, @y+@ry, @zorder, @angle, @center_x, @center_y, @factor_x, @factor_y, @color, @mode
  end
  
  def inspect
    "#<#{part[0]}:#{part[1]} @ #{rx}/#{ry} in #{frame[0]}:#{frame[1]}>"
  end
end
end