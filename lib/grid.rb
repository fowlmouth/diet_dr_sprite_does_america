
class Grid
  GRIDCOLOR = ::Gosu::Color::argb(50, 255, 255, 255)
  class << self
    def [] key
      return unless key.is_a? Array
      @grids ||= {}
      if @grids.has_key? key
        @grids[key]
      else
        #create one, key is [width, height]
        w,h,fx,fy = *key
        fx ||= $window.factor
        fy ||= $window.factor
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
        
        #w.times {   |x|
        #  h.times { |y|
        #    i.line x*fx, y*fy, w*fx, h*fy, color: GRIDCOLOR
        #  }
        #}
        @grids[key] = i
      end
    end
    
    def game_obj key, options = {}
      Chingu::GameObject.create({image: self[key], factor_x: 1, factor_y: 1, zorder: ZOrder::GRID}.merge(options))
    end
  end
end
