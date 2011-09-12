
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
    @previews = []
    @layoutbs = []
    
    cant_get_it_up?
    new_breakthroughs_in_medical_science_show_promising_results
    for_your_problems_you_need_look_no_further
    grow_yo_coque_is_a_new_product_that_is_guaranteed_to
    
    self.input = %w{wheel_up wheel_down mouse_left}.map &:intern # :>
    #self.input = {p: -> { binding.pry }}
  end
  
  #TODO factor these two methods into a new class that handles this shit
  def cant_get_it_up?
    dir = @dat['parts']['dir']
    @dat['parts'].each { |key, value|
      next unless key.is_a? Symbol
      @parts[key] = Chingu::Animation.new file: File.join(dir, value)
    }
    return
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
    @dat[:animations].each { |name, stuff|
      @animation[name] = []
      stuff[:frames].each { |f|
        # start with a blank image
        @animation[name] << TexPlay.create_blank_image($window, stuff[:size][0], stuff[:size][1], color: :alpha)
        f.each { |n, p|
          # copypasta
          @animation[name].last.splice @parts[n][p[0]], p[1], p[2]
        }
      }
    }
  end

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
        x: 300, y: y, zorder: 100)
      y += frizzames.first.height * $window.factor + 10
    }
  end
  
  def grow_yo_coque_is_a_new_product_that_is_guaranteed_to
    x = 15
    @parts.each { |name, anim|
      #i = TexPlay.create_blank_image $window, 20, 16, color: INACTIVE_LAYER
      b = Gui::Button.create(text: name, size: 14, x: x, y: 0, color: INACTIVE_LAYER, factor: 2, zorder: ZOrder::UI_TEXT)
      w,h = b.width, b.size
      i = TexPlay.create_blank_image($window, w+2, h+2, color: :black)
      i.paint {
        #this is majorly wrong
        fill 0,0, color: :black
        line 0,0,   0,h+2, color: :blue
        line 0,h+2, w+2,h+2, color: :blue
        line w+2,h+2, w+2,0, color: :blue
      }
      @layoutbs << [b, Chingu::GameObject.create(image: i, x: x-2, y: 0, zorder: ZOrder::UI_BG, factor: 2), name]
      x += b.width+2
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
    fu, mx, my = false, $window.mouse_x, $window.mouse_y
    @layoutbs.each { |b|
      if b[0].collision_at? mx, my
        fu = true
        select_layer b[2]
      end
    }
    #other shit to collide with:
    #indiv. frames/parts
    #..
  end
  
  def select_layer name
    
  end
end
end
