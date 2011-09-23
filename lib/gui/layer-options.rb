module Gui
class LayerOptionsWidget

attr_reader :visible, :objects, :index

def initialize options = {}
  @visible = options.has_key?(:visible) ? options[:visible] : false
  #this just keeps track of certain items..
  @objects = {}
  @x, @y = options[:x], options[:y]
end

def clean
  @objects.each { |name, object|
    object.destroy if object.respond_to? :destroy
  }
  @index = 0
end
  
def track p_type, p_name, part, relative_object
  clean
  #x, y = 250, relative_object.y
  x, y = @x, @y
  
  #what would you call this, fxrubyish or shoesish?
  #possible future names for this stuff:
  # PoopUI, MetroSexUI, 
  @objects[:name] = Chingu::Text.create \
    text: "#{p_type}/#{p_name}",
    size: 16, factor: 1,
    x: x, y: y,
    rotation_center: :top_left
  
  width, height = @objects[:name].width, @objects[:name].size
  framew, frameh = part[0].width, part[0].height
  factor = 1.0 * width / part[0].width
  @objects[:preview] = SpriteEdit::FrameSet.create \
    anim: part.frames,
    image: part[0],
    x: x, y: (y+=16),
    rotation_center: :top_left,
    factor: factor, zorder: ZOrder::FRAME
  @objects[:grid] = SpriteEdit::Grid.game_obj(
    [framew, frameh, factor, factor],
    { x: x, y: y})
  @objects[:bg] = Chingu::GameObject.create\
    x: x, y: y, image: $window.pixel, color: $window.current.session[:background],
    factor_x: @objects[:grid].width, factor_y: @objects[:grid].height,
    rotation_center: :top_left, zorder: ZOrder::FRAME-1
  
  @objects[:button_back] = Gui::Button.create \
    image: Gui.icon(:left_arrow),
    x: x, y: (y+=@objects[:preview].height),
    factor: 1,
    click: proc { self.index = @objects[:preview].last },
    rotation_center: :top_left
  @objects[:offset] = Gui::Text.create \
    text: "#{@index} / #{@objects[:preview].anim.size}", size: 16,
    factor: 1, x: @objects[:button_back].width+x, y: y,
    rotation_center: :top_left
  @objects[:button_forward] = Gui::Button.create \
    image: Gui.icon(:left_arrow),
    x: @objects[:offset].x + @objects[:offset].width + 16, y: y,
    factor_x: -1, factor_y: 1,
    click: proc { self.index = @objects[:preview].next },
    rotation_center: :top_left

  @objects[:add_part] = Gui::Text.create \
     text: 'Add to frame',
     x: x, y: (y+=@objects[:button_forward].height),
     factor: 1, click: proc { |button|
       if af = $window.current.active_frame
        $window.current.add_part_to_frame [p_type, p_name, self.index], [af[1], af[2]], [0, 0]
       end
     }
  
  last_obj = @objects[:add_part]
  if last_obj.y + last_obj.height > $window.height
    diff = ($window.height - last_obj.y + last_obj.height) * $window.factor
    @objects.values.each { |o|
      o.y = o.y - diff
    }
  end
end

#
def show; self.visible = true;  end
def hide; self.visible = false; end
def visible= bool
  @objects.values.each { |o|
    o.visible = bool if o.respond_to? :visible=
  }
  @visible = bool
end
alias show! show
alias hide! hide

def index= value
  @index = value
  @objects[:offset].text = "#{value} / #{@objects[:preview].anim.size}"
end

end
end
