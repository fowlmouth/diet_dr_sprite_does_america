
module SpriteEdit
class AnimatedPreview < Chingu::GameObject
trait :bounding_box, debug: DEBUG
include Gui::Clickable
def initialize options = {}
  options = {
    delay: 200,
    bounce: false,
    zorder: ZOrder::PREVIEW,
    rotation_center: :top_left 
  }.merge options
  super options
  
  @f_name = options[:f_name]
  @delay = options[:delay]
  @bounce = options[:bounce]
  
  @f_width, @f_height = *options[:f_size]
  
  @frames = @anim = nil
  
  @x, @y = $window.width - (frames[0].width * factor), 50
  
  if options[:bg_color]
    @bg = Chingu::GameObject.create(
      x: x, y: y,
      factor_x: anim[0].width*factor_x, 
      factor_y: anim[0].height*factor_y, 
      image: $window.pixel, 
      color: options[:bg_color],
      rotation_center: :top_left,
      zorder: zorder - 1) 
  end
  @paused = false
end

def frames
  unless @frames
    @frames = []
    $window.current.animation[@f_name].size.times { |fff|
      update_frame fff
    }
  end
  @frames
end

def update_frame offset
  i = TexPlay.create_blank_image($window, @f_width, @f_height, color: :alpha)
  $window.current.animation[@f_name][offset].each { |part|
    p part
    i.splice part.image, part.rx, part.ry, chroma_key: :alpha
  }
  @frames[offset] = i
end

def anim
  @anim ||= GhettoAnimation.new(frames: frames, delay: @delay, bounce: @bounce)
  @anim
end

def update
  super
  @image = anim.next unless @paused
end

end

class PreviewMenu

def initialize
  
end

end

end
