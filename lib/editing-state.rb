
module SpriteEdit
class EditingState < Chingu::GameState
  
ACTIVE_LAYER = Gosu::Color::GREEN
INACTIVE_LAYER = Gosu::Color::BLUE

attr_reader :active_frame, :parts, :session, :animation

def setup
  abort unless @options[:file]
  @file = @options[:file]
  @dat = YAML.load_file File.expand_path(@file)
  
  @parts, @animation, @previews = {}, {}, {}
  
  @layer_buttons, @active_layer, @active_frame, @selected_part = {}, nil, nil, nil
  @active_tool, @tools, @grids = nil, {}, {}
  
  @session = {
    factor: $window.factor, #editting factor
    background: ::Gosu::Color::BLACK, #background color of frames
    delay: 200, #default animation delay for previews
  }
  if @dat.has_key?(:editor)
    @session[:factor] = @dat[:editor][:factor] if @dat[:editor].has_key?(:factor)
    if @dat[:editor].has_key?(:background)
      @session[:background] = ::Gosu::Color.new(255, *@dat[:editor][:background])
    end
    @session[:delay] = @dat[:editor][:delay] if @dat[:editor].has_key?(:delay)
  end
  #binding.pry
  
  @cursor = Gui::Cursor.create
  
  Grid.background_color = @session[:background]
  
  load_parts
  
  @dat[:animations].each { |name, anim|
    if anim.has_key? :random_frames
      @dat[:animations][name][:frames] = (0..anim[:random_frames][1]-1).map { [[anim[:random_frames][0], rand(@parts[anim[:random_frames][0]].frames.size), 0, 0]] }
    end
  }
  
  load_frames
  
  load_preview
  
  layer_buttons
  
  @layer_widget = Gui::LayerOptionsWidget.new visible: false, x: 10, y: 400
  @frame_widget = Gui::FrameOptionsWidget.new visible: false
  
  self.input = {
    p: -> { binding.pry },
    wheel_up: :wheel_up,
    wheel_down: :wheel_down,
    mouse_left: :mouse_left,
    holding_mouse_left: :holding_mouse_left,
    mouse_right: :clear
  }
  
end

#TODO factor these two methods into a new class that handles this shit
def load_parts
  #dir = @dat['parts']['dir']
  #@dat['parts'].each { |key, value|
  #  next unless key.is_a? Symbol
  #  @parts[key] = Chingu::Animation.new file: File.join(dir, value)
  #}
  #possibly all images in parts/ should be cached so they are readily available, instead
  #of just the parts defined in the yml. 
  Dir.glob File.join(%w(media parts */*.png)) do |p|
    #replace this regex later
    fname, type, name = *p.match(/^media\/parts\/(\w+)\/(.*)\.png$/)
    @parts[type] ||= {}
    @parts[type][name] = Chingu::Animation.new file: fname
  end
end

def load_frames
  x, y = 115, 20
  @dat[:animations].each { |name, stuff|
    @animation[name], @grids[name] = [], []
    mx = x
    stuff[:frames].each_with_index { |f, i|
      @animation[name][i] = []
              
      @grids[name] << Grid.game_obj(
        [stuff[:size][0], stuff[:size][1], @session[:factor], @session[:factor]],
        x: mx, y: y, bg_color: @session[:background], click: proc { |button|
          self.active_frame = [button, name, i]
      })
      
      f.each_with_index { |p, z|
        #TODO at saving time compare each part's image to the corresponding in @parts[:name][offset]
        #if it is different, tack the new one on at the end of the sheet and update the offset
        #in the YAML.
        #note to self: rx/ry are relative x/y where the part should be drawn in the animation
        #at draw time they should be added to the frame's x/y on the screen so they line up properly
        #this should probably be done in SpritePart#update so we need to pass something to reference
        #off of..
        #currently a frame record is like this [:foot, offset, x, y]
        #in the future will probably have more things like angle, color, moar?
        #ALSO, parts are going to store their own name and offset and the image associated with it.
        #i dont think it is possible to pull the image from @parts from inside the part without using a factory
        #or some shit like Grid method which i'd like to avoid. so let's just be redundant :
        
        pArTtYpE, pArTnAmE = *p[0].split('/')
        add_part_to_frame [pArTtYpE, pArTnAmE, p[1]], [name, i], [p[2], p[3]], z
      }
      
      mx += stuff[:size][0] * @session[:factor] + 15
    }
    
    y += stuff[:size][1] * @session[:factor] + 15
  }
  
end

def active_frame= frame = nil
  if frame.nil?
    @active_frame = nil
    @frame_widget.clean
    return
  end
  rel_obj, name, index = *frame
  @active_frame = [rel_obj, name, index]
  @frame_widget.track name, index, @animation[name][index]
end

def load_preview anim_name = nil
  #make a local copy of the animation to be generated, if only one is selected
  animation = anim_name && @animation.has_key?(anim_name) \
    ? { anim_name => @animation[anim_name] } \
    : @animation
  return if @previews[anim_name]
  animation.each { |name, frames|
    #how to build a new image from a bunch of gameobjects?
    #i guess pull out the images and splice them together..
    #this isnt going to be fun
    #actually its not that bad
    #hillshire farms, GO MEAT
    @previews[name] = AnimatedPreview.create(
      f_name: name,
      f_size: @dat[:animations][name][:size],
      delay: @dat[:animations][name][:delay] || @session[:delay],
      bounce: @dat[:animations][name].has_key?(:bounce) && @dat[:animations][name][:bounce] ? true : false,
      bg_color: @session[:background])
      #first.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first
  }
end

def update_preview f_name, f_frame = nil
  @previews[f_name].update_frame f_frame
end

def layer_buttons
  x, y = 10, 10
  
  if @layer_buttons
    @layer_buttons.each { |k,v|
      v.map &:destroy
    }
  end
  @layer_buttons = {}
  
  @parts.each { |type, partz|
    @layer_buttons[type] = {
      type.intern => Gui::Text.create(
        text: type, size: 16, 
        x: x, y: y, color: INACTIVE_LAYER, 
        factor: 1, zorder: ZOrder::UI_TEXT,
        click: proc {
          self.toggle_layer_tree type
        })}
    partz.each { |name, p|
      y += 16 + 4
      @layer_buttons[type][name] = Gui::Text.create \
        text: name, size: 16,
        x: x + 15, y: y, color: INACTIVE_LAYER,
        factor: 1, zorder: ZOrder::UI_TEXT,
        click: proc {
          self.active_layer = [type, name]
        }
    }
    #w,h = b.width, b.size
    #i = TexPlay.create_blank_image($window, w+2, h+2, color: :black)
    #i.paint {
      #this is majorly wrong
    #  fill 0,0, color: :black
    #  line 0,0,   0,h+2, color: :blue
    #  line 0,h+2, w+2,h+2, color: :blue
    #  line w+2,h+2, w+2,0, color: :blue
    #}
    y += 16 + 4
  }
end

def toggle_layer_tree layer_type
  @layer_buttons.each { |name, layers|
    if name == layer_type
      #binding.pry
      layers.each { |n, l|
        if n.is_a? Symbol
          l.text = l.visible? ? "#{n} [hidden]" : "#{n}"
        else
          binding.pry
          l.visible= l.visible? ? false : true
        end
      }
    end
  }
end

def add_part_to_frame part, frame, pos = [0, 0], zorder = nil
  #binding.pry
  
  zorder ||= @animation[frame[0]][frame[1]].size
  
  @animation[frame[0]][frame[1]] << SpritePart.create(
    part: [part[0], part[1], part[2]],
    rx: pos[0], ry: pos[1],
    frame: [frame[0], frame[1]],
    image: @parts[part[0]][part[1]][part[2]],
    x: @grids[frame[0]][frame[1]].x, y: @grids[frame[0]][frame[1]].y,
    factor: @session[:factor],
    zorder: ZOrder::FRAME + zorder)
end

#NOT USED
def add_layer_button name, x, y
  
  b = Gui::Text.create \
    text: name.to_s, size: 16,
    x: x, y: y, color: Gui::INACTIVE_LAYER,
    factor: 1, zorder: ZOrder::UI_TEXT
  
end

def update
  if @selected_part && !$window.button_down?(Gosu::MsLeft)
    #update the preview associated with @selected_part
    update_preview @selected_part.frame[0], @selected_part.frame[1]
    @selected_part = nil
    @cursor.action nil
    @ox = @oy = nil
    $-.out 'Cleared selection'
  end
  super
end

def draw
  super
  if @active_frame
    $window.draw_rect [@active_frame[0].x, @active_frame[0].y, @active_frame[0].width, @active_frame[0].height], ACTIVE_LAYER, ZOrder::GRID
  end 
end

def wheel_down
  #find location of pointer, if in the middle scroll down, if in the layer selection area scroll right
end

def wheel_up
  #^^;
end

def mouse_left
  #rook for a corrision
  mx, my = $window.mouse_x, $window.mouse_y
  
  #clean this up later
  game_objects.each { |o|
    if o.respond_to?(:click) && o.collision_at?(mx, my)
      o.click o
      return
    end
  }
  
  
  #other shit to collide with:
  #indiv. frames/parts
  #..
end

def holding_mouse_left
  mx, my = $window.mouse_x, $window.mouse_y
  if @selected_part
    #drag
    dx = (mx-@ox)/@selected_part.factor_x
    dx = dx > 0 ? dx.floor : dx.ceil
    dy = (my-@oy)/@selected_part.factor_y
    dy = dy > 0 ? dy.floor : dy.ceil
    $-.out "%d,%d  from    %d,%d    diff %d,%d  ...  %d,%d" % \
      [mx, my, @ox, @oy, mx-@ox, my-@oy, dx, dy].map(&:to_i)
    
    if dx != 0
      @selected_part.rx += dx
      @ox = mx
    end
    if dy != 0
      @selected_part.ry += dy
      @oy = my
    end
  else
    #select a part
    $-.out "Selecting a part at #{mx},#{my}"
    self.select_part mx, my
  end
end

def clear
  @selected_part = nil
  self.active_layer = nil
  @cursor.action = nil
  @ox = @oy = nil
end

def active_layer= p = nil
  if @active_layer.is_a?(Array) && @active_layer
    @layer_buttons[@active_layer[0]][@active_layer[1]].color = INACTIVE_LAYER
  end
  
  if p.nil?
    @active_layer = nil
    return
  end
  
  type, name = *p
  
  unless @layer_buttons.has_key?(type) && @layer_buttons[type].has_key?(name)
    abort "not a layer? #{type} - #{name}"
  end
  
  button = @layer_buttons[type][name]
  button.color = ACTIVE_LAYER
  @layer_widget.track type, name, @parts[type][name], button
  
  @active_layer = [type, name]
end

def select_part x, y
  #x/y is absolute mouse_x/mouse_y
  #parts have x/y of the frame so collision must be detected with x+(rx*factor), y+(ry*factor)
  return unless @active_layer
  
  @animation.each { |name, frames|
    frames.each { |parts|
      parts.select { |p| p.part[0..1] == @active_layer }.each { |p|
        if p.collision_at?(x, y)
          ax = (x-p.x).to_i/p.factor_x
          ay = (y-p.y).to_i/p.factor_y
          unless p.image.transparent_pixel?(ax, ay)
            $-.out "Selected #{p.part[0]}:#{p.part[1]} in frame #{p.frame[0]}:#{p.frame[1]}"
            @ox, @oy = x, y
            @selected_part = p
            @cursor.action = :move
            return
          end
        end
      }
    }
  }
end
  
end
end

