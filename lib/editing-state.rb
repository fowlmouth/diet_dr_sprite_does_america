
module SpriteEdit
class EditingState < Chingu::GameState
  
  ACTIVE_LAYER = Gosu::Color::GREEN
  INACTIVE_LAYER = Gosu::Color::BLUE
  
  def setup
    abort unless @options[:file]
    @file = @options[:file]
    @dat = YAML.load_file File.expand_path(@file)
    
    @parts = {}
    @animation = {}
    @previews = {}
    
    @layerbs = {}
    @active_layer = nil
    
    @cursor = Gui::Cursor.create
    
    cant_get_it_up?
    new_breakthroughs_in_medical_science_show_promising_results
    #for_your_problems_you_need_look_no_further
    grow_yo_coque_is_a_new_product_that_is_guaranteed_to
    
    
    self.input = {
      p: -> { binding.pry },
      wheel_up: :wheel_up,
      wheel_down: :wheel_down,
      mouse_left: :mouse_left,
      holding_mouse_left: :holding_mouse_left
    }
  end
  
  #TODO factor these two methods into a new class that handles this shit
  def cant_get_it_up?
    dir = @dat['parts']['dir']
    @dat['parts'].each { |key, value|
      next unless key.is_a? Symbol
      @parts[key] = Chingu::Animation.new file: File.join(dir, value)
    }
    #possibly all images in parts/ should be cached so they are readily available, instead
    #of just the parts defined in the yml. 
#    Dir.glob File.join('media', 'parts', '*') do |p|
#      if File.directory? p
#        part = File.basename p
#        @parts[part] ||= {}
#        Dir.glob File.join(p, '*.png') do |f|
#          @parts[part][File.basename(f)] = Chingu::Animation.new file: f
#        end
#      end
#    end
  end
  
  def new_breakthroughs_in_medical_science_show_promising_results
    x, y = 50, 50
    @dat[:animations].each { |name, stuff|
      @animation[name] = []
      mx = x
      stuff[:frames].each_with_index { |f, i|
        @animation[name][i] = []
        #@animation[name] << TexPlay.create_blank_image($window, stuff[:size][0], stuff[:size][1], color: :alpha)
        #f.each { |p|
          # copypasta
        #  @animation[name].last.splice @parts[p[0]][p[1]], p[2], p[3], chroma_key: :alpha
        #}
        
        g = Grid.game_obj [stuff[:size][0], stuff[:size][1], $window.factor, $window.factor], x: mx, y: y
        
        f.each { |p|
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
          @animation[name][i] << SpritePart.create(
            part: [p[0], p[1]],
            image: @parts[p[0]][p[1]], rx: p[2], ry: p[3],
            frame: [name, i], x: g.x, y: g.y,
            zorder: ZOrder::FRAME + i)
        }
        
        mx += stuff[:size][0] * $window.factor + 15
      }
      
      y += stuff[:size][1] * $window.factor + 15
    }
    
    generate_preview
  end
  
  def generate_preview anim_name = nil
    #make a local copy of the animation to be generated, if only one is selected
    animation = anim_name && @animation.has_key?(anim_name) \
      ? { anim_name => @animation[anim_name] } \
      : @animation
    
    animation.each { |name, frames|
      #how to build a new image from a bunch of gameobjects?
      #i guess pull out the images and splice them together..
      #this isnt going to be fun
      #actually its not that bad
      #hillshire farms, GO MEAT
      derp = []
      w,h = *@dat[:animations][name][:size]
      frames.each { |fff|
        i = TexPlay.create_blank_image($window, w, h, color: :alpha)
        fff.each { |f|
          i.splice f.image, f.rx, f.ry, chroma_key: :alpha
        }
        derp << i
      }
      @previews[name].destroy if @previews.has_key? name
      @previews[name] = AnimatedPreview.create(
        anim: GhettoAnimation.new(
          frames: derp,
          delay: @dat[:animations][name][:delay],
          bounce: @dat[:animations][name].has_key?(:bounce) && @dat[:animations][name][:bounce] ? true : false),
        x: ($window.width-20-(derp.first.width*$window.factor)),
        y: frames.first.first.y, zorder: ZOrder::PREVIEW,
        rotation_center: :top_left)
        #first.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first.first
    }
  end

  #deprecated, combined into the above two functions
  def for_your_problems_you_need_look_no_further
    x, y = 100, 100
    @animation.each { |name, frizzames|
      # create ein gameobject vor each frame, UND EIN PREVIEW
      mx = x
      frizzames.each { |fff|
        #replace later with an object that responds to clicks drags etc
        #or maybe an object for each part. yeah. probably that.
        Grid.game_obj [fff.width, fff.height, $window.factor, $window.factor], x: mx, y: y
        Chingu::GameObject.create image: fff, x: mx, y: y, zorder: 100
        mx += fff.width * $window.factor + 10
      }
      @previews << AnimatedPreview.create(anim: GhettoAnimation.new(frames: frizzames),
        x: ($window.width-20-(frizzames.first.width*$window.factor)), 
        y: y, zorder: 100)
      y += frizzames.first.height * $window.factor + 10
    }
  end
  
  def grow_yo_coque_is_a_new_product_that_is_guaranteed_to
    x = 15
    @parts.each { |name, anim|
      b = Gui::Button.create(
        text: name.to_s, size: 14, 
        x: x, y: 0, color: INACTIVE_LAYER, 
        factor: 2, zorder: ZOrder::UI_TEXT)
      #w,h = b.width, b.size
      #i = TexPlay.create_blank_image($window, w+2, h+2, color: :black)
      #i.paint {
        #this is majorly wrong
      #  fill 0,0, color: :black
      #  line 0,0,   0,h+2, color: :blue
      #  line 0,h+2, w+2,h+2, color: :blue
      #  line w+2,h+2, w+2,0, color: :blue
      #}
      @layerbs[name] = b
      x += b.width+6
    }
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
    @layerbs.each { |name, b|
      if b.collision_at? mx, my 
        self.active_layer = name
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
      #@selected_part is [ :animation_name, ]
    else
      #select a part
      self.select_part mx, my
    end
  end
  
  def active_layer= name
    return unless @layerbs.has_key? name
    @layerbs.each { |n, b| b.color = n == name ? ACTIVE_LAYER : INACTIVE_LAYER }
    @active_layer = name
  end
  
  def select_part x, y
    #x/y is absolute mouse_x/mouse_y
    #parts have x/y of the frame so collision must be detected with x+(rx*factor), y+(ry*factor)
    return unless @active_layer
    
    # temp. working with just the first frame of the first animation
    o = @animation[:cycle].first.first
    #puts "MOUSE #{x}/#{y}"
    #puts "PART           #{o.x + (o.rx*o.factor_x)}/#{o.y + (o.ry*o.factor_y)}"
    
    if o.collision_at?(x, y)
      puts 'COLLIDE?'
      ax, ay = x-o.x, y-o.y
      #if o.image.transparent_pixel?(
      binding.pry
    end
    
    return
    
    @animation.each { |name, frames|
      frames.each { |parts|
        parts.select { |p| p.part[0] == @active_layer }.each { |p|
          if p.collision_at?(x+p.x+(p.x*p.factor_x), y+p.y+(p.ry*p.factor_y))
            puts "Selected #{p.part[0]}:#{p.part[1]} in frame #{p.frame[0]}:#{p.frame[1]}"
            return
          end
        }
      }
    }
  end
end
end
