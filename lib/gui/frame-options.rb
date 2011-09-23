module Gui
class FrameOptionsWidget

ACTIVE_COLOR = ::Gosu::Color::GREEN
DISABLED_COLOR = ::Gosu::Color::GRAY

def initialize options = {}
  @visible = options.has_key?(:visible) ? options[:visible] : false
  @objects = {}
end

def clean o = @objects
  @objects.each { |n, o|
    if o.is_a? Array
      deep_destroy o
    elsif o.respond_to?(:destroy)
      o.destroy
    end
  }
end

def deep_destroy array
  array.each { |x|
    if x.is_a? Array
      deep_destroy x
    elsif x.respond_to?(:destroy)
      x.destroy
    end
  }
end

def track f_name, f_index, f_stuff
  clean
  @objects = {}
  
  @f_name, @f_index, @f_stuff = f_name, f_index, f_stuff
  
  ox, y = 500, 200
  
  @objects[:parts] = []
  f_stuff.size.times { |n|
    x = ox
    @objects[:parts][n] = []
    @objects[:parts][n] << Gui::Button.create(
      _index: n,
      image: Gui.icon(:left_arrow),
      color: ::Gosu::Color::GREEN,
      factor: 1,
      rotation_center: :center,
      x: x, y: y, angle: 90, click: proc { |button|
        self.lower_part button.options[:_index]
      })
    @objects[:parts][n] << Gui::Button.create(
      _index: n,
      image: Gui.icon(:left_arrow),
      color: ::Gosu::Color::GREEN,
      x: x += 16,
      y: y, rotation_center: :center, 
      angle: 270, factor: 1, click: proc { |button|
        self.raise_part button.options[:_index]
      })
    @objects[:parts][n] << Gui::Button.create(
      _index: n,
      image: Gui.icon(:minus),
      color: ::Gosu::Color::RED,
      x: x += 16, #@objects[:parts][n][-1].width,
      y: y, factor: 1,
      rotation_center: :center, click: proc { |button|
        self.remove_part button.options[:_index]
      })
    #TODO add part visibility, either per-frame or per-animation
    #visibility = 
    #@objects[:parts][n] << Gui::Button.create(
    #  _index: n,
    #  image: get_visibility
    #  )
    @objects[:parts][n] << Gui::Text.create(
      _index: n,
      text: "#{f_stuff[n].part[0]}/#{f_stuff[n].part[1]}:#{f_stuff[n].part[2]}",
      size: 16,
      factor: 1,
      x: x += 8, y: y - 8,
      rotation_center: :top_left,
      click: proc {
        $window.current.active_layer = [*f_stuff[n].part[0..1]]
      })


    y += 16
  }
  
  clip_clop
end

def clip_clop
  @objects[:parts].each_with_index { |arr, i|
    if i == 0
      # disable lower button
      arr[0].color = DISABLED_COLOR
    else
      arr[0].color = ACTIVE_COLOR
    end
    
    if i == @objects[:parts].size-1
      # disable raise button
      arr[1].color = DISABLED_COLOR
    else
      arr[1].color = ACTIVE_COLOR
    end
    
    #TODO
    #change eye icon to reflect if the part is visible (that i also need to do)
  }
end

#herein lies deception
def raise_part which
  $-.out "RAISE PART #{which}"
  if which == $window.current.animation[@f_name][@f_index].size - 1 
    $-.out 'cannot raise part any higher'
    return
  end
  @f_stuff[which], @f_stuff[which+1] = @f_stuff[which+1], @f_stuff[which]
  @f_stuff[which+1].zorder += 1
  @f_stuff[which].zorder   -= 1
  @objects[:parts][which], @objects[:parts][which+1] = @objects[:parts][which+1], @objects[:parts][which]
  @objects[:parts][which+1].each { |_| _.y += 16; _.options[:_index] += 1 }
  @objects[:parts][which].each   { |_| _.y -= 16; _.options[:_index] -= 1 }
  update_preview
end

def lower_part which
  $-.out "LOWER PART #{which}"
  if which == 0
    $-.out 'cannot lower part'
    return
  end
  @f_stuff[which], @f_stuff[which-1] = @f_stuff[which-1], @f_stuff[which]
  @f_stuff[which-1].zorder -= 1
  @f_stuff[which].zorder   += 1
  @objects[:parts][which], @objects[:parts][which-1] = @objects[:parts][which-1], @objects[:parts][which]
  @objects[:parts][which-1].each { |_| _.y -= 16; _.options[:_index] -= 1 }
  @objects[:parts][which].each   { |_| _.y += 16; _.options[:_index] += 1 }
  #BAM
  update_preview
end

def remove_part which
  @f_stuff[which].destroy
  @f_stuff.delete_at which
  @objects[:parts][which].each { |_| _.destroy }
  @objects[:parts].delete_at which
  if @f_stuff.size > 0
    @f_stuff[which..-1] = @f_stuff[which..-1].map { |part|
      part.zorder -= 1
      part
    }
    @objects[:parts][which..-1] = @objects[:parts][which..-1].map { |buttonz|
      buttonz.each { |b| b.y -= 16; b.options[:_index] -= 1 }
      buttonz
    }
  end
  update_preview
end

def update_preview
  clip_clop
  $window.current.update_preview @f_name, @f_index
end

end
end
