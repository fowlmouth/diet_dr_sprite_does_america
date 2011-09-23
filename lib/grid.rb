module SpriteEdit
module Grid

  GRIDCOLOR = ::Gosu::Color::argb(50, 255, 255, 255)
  TEMP = []
  @grids = {}
  @background_color, @background_objects = nil, []
  
  def self.[] key
    return unless key.is_a? Array
    
    key = [key[0], key[1], $window.factor, $window.factor] unless key.size == 4
    key[2] = key[2].floor
    key[3] = key[3].floor
    
    return @grids[key] if @grids.has_key? key
    
    #otherwise create one, key is [width, height, factor_x, factor_y]
    #image is drawn full size so it doesn't get blown up and look weird later
    w,h,fx,fy = *key
    i = TexPlay.create_blank_image $window, w*fx, h*fy, color: :alpha
    (w/2).times { |x|
      next if x == 0 || x == w/2
      #i.line x*2*fx, 0, x*2*fx, h*fy, color: GRIDCOLOR
      x1, y1 = x*2*fx, 0
      x2, y2 = x*2*fx, h*fy
      (y1..y2).each { |p|
        next if p%3 != 0
        i.pixel x1, p, color: GRIDCOLOR
      }
    }
    (h/2).times { |y|
      next if y == 0 || y == h/2
      #i.line 0, y*2*fy, w*fx, y*2*fy, color: GRIDCOLOR
      x1, y1 = 0, y*2*fy
      x2, y2 = w*fx, y*2*fy
      (x1..x2).each { |p|
        next if p%3 != 0
        i.pixel p, y1, color: GRIDCOLOR
      }
    }
    
    @grids[key] = i
  end
  
  def self.background_color= color
    @background_color = color
  end
  
  def self.game_obj key, options = {}
    if color = options.delete(:bg_color)
      @background_objects << Chingu::GameObject.create(
        options.merge({
          image: $window.pixel,
          factor_x: key[0]*key[2],
          factor_y: key[1]*key[3],
          zorder: ZOrder::FRAME-1,
          rotation_center: :top_left,
          color: color}))
    end
    Gui::Button.create({image: self[key], factor_x: 1, factor_y: 1, zorder: ZOrder::GRID, rotation_center: :top_left}.merge(options))
  end

end
end
