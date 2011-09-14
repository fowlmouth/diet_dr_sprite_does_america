
module Gui
class Cursor < Chingu::GameObject

  trait :collision_detection
  trait :bounding_box

  attr_reader :x, :y

  def setup
    self.rotation_center = :center
    @animation = Chingu::Animation.new(
      file:  'media/gui/cursor.png',
      size:  [5,5],
      delay: 100)
    @image = @animation.first
    self.factor = 2
  end

  def update
    @image = @animation.next
  end

  def draw
    @image.draw $window.mouse_x, $window.mouse_y, ZOrder::CURSOR, self.factor, self.factor
  end
end

#calculates position against a viewport
class VPCursor < Cursor
  def update
    @x = $window.mouse_x + $window.current_game_state.viewport.x
    @y = $window.mouse_y + $window.current_game_state.viewport.y
    super
  end
end

end
