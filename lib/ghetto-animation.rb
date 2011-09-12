module SpriteEdit
class GhettoAnimation < Chingu::Animation
  #this is ripped from chingu
  #i just needed an animation class that takes individual frames
  def initialize options = {}
    options = {:step => 1, :loop => true, :bounce => false, :index => 0,
      :delay => 100, :frames => []}.merge(options)
    
    @loop = options[:loop]
    @bounce = options[:bounce]
    @frames = options[:frames]
    @index = options[:index]
    @delay = options[:delay]
    @step = options[:step] || 1
    @dt = 0
    
    @sub_animations = {}
    @frame_actions = []
    
    @width = @frames.first.width
    @height= @frames.first.height
  end
  
end
end
