
module Gui
class Cursor < Chingu::GameObject

  trait :collision_detection
  trait :bounding_box

  attr_reader :x, :y

  def setup
    self.rotation_center = :top_left
    @animation = Chingu::Animation.new \
      file:  'media/gui/cursor.png',
      size:  [15, 15],
      delay: 100
    @images = { default: @animation[0], move: @animation[1] }
    @image = @images[:default]
    self.factor = 1.5
    action nil
  end
  
  def action a = nil
    @image = @images[a.nil? ? :default : a]
  end
  alias_method :action=, :action

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
