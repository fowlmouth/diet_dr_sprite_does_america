
module SpriteEdit
class FrameSet < Chingu::GameObject

attr_reader :anim

def initialize options = {}
  super options
  abort 'you have to pass :anim => [array of images] to AnimatedSprite ' unless @anim = options[:anim]
  @index = 0
end

def next
  @image = @anim[@index = (@index+1)%@anim.size]
  @index
end

def last
  @image = @anim[@index = (@index-1)%@anim.size]
  @index
end


end
end
