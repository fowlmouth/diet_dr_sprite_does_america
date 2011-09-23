module SpriteEdit
class Window < Chingu::Window
  
  alias current current_scope
  attr_reader :pixel
  
  def initialize
    super 1024, 640, false
    self.factor = 4
    self.input = { escape: :exit }# left_mouse_button: :lclick }
    retrofy
    
    @pixel = ::Gosu::Image['media/pixel.png']
    
    #push_game_state LoadingState
    push_game_state EditingState.new(file: (ARGV[0] or Settings.default_file))
  end
  
  def update
    super
    self.caption = "Mouse @ #{mouse_x}/#{mouse_y}"
  end
  
end
end
