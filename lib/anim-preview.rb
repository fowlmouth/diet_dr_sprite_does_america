
module SpriteEdit
class AnimatedPreview < Chingu::GameObject
  
  def initialize options = {}
    super options
    abort 'you have to pass :anim => [array of images] to AnimatedSprite ' unless @anim = options[:anim]
  end
  
  def update
    super
    @image = @anim.next
  end
  
end
end
