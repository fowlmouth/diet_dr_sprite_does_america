
#TODO
#replace all of this with some gui lib
#this state should do all the loading thats done in EditingState 
module SpriteEdit
class LoadingState < Chingu::GameState

  def initialize
    super
    @title = Chingu::Text.create text: 'Enter path to image', x: 10, y: 10, size: 14, factor: 2
    @inp = Gui::TextField.create text: './media/character.png', x: 30, y: 100, size: 14, factor: 1, caret_color: ::Gosu::Color::RED
    @cursor = Gui::Cursor.create
    @loadb = Gui::Button.create text: 'Load', x: 30, y: 100+(14*3), size: 14, factor: 2, color: ::Gosu::Color::GREEN
    @go = Gui::Button.new text: 'Edit ->', x: $window.width - 50, y: $window.height - 50, size: 14, factor: 2, color: ::Gosu::Color::GREEN
    @preview = nil
    
    self.input = { left_mouse_button: :lclick }
  end
  
  def draw
    super
    if @preview
      @preview.draw
      @go.draw
    end
    
  end

  def lclick
    if @inp.collision_at? $window.mouse_x, $window.mouse_y
      @inp.select $window.mouse_x
      binding.pry
    else
      @inp.unselect
      if @loadb.collision_at? $window.mouse_x, $window.mouse_y
        wrap do
          @preview.destroy if @preview
          @preview = Chingu::GameObject.new image: @inp.text, x: 100, y: 150, zorder: ZOrder::PREVIEW, rotation_center: :top_left
          @title.text = "Showing #{@inp.text}"
        end
      elsif @preview && @go.collision_at?($window.mouse_x, $window.mouse_y)
        push_game_state EditingState.new(file: './media/redchar.yml')
      end
    end
  end

  def wrap text = 'Invalid path to filename'
    begin
      yield
    rescue
      @title.text = text
    end
  end
end
end
