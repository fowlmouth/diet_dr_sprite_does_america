module Gui

module Clickable
  def click *args
    @options[:click].call *args if @options[:click]
  end
end

module Common
  def toggle_visibility; self.visible = !@visible; end
end

#TODO merge these head-on style
#blood everywhere
class Text < Chingu::Text
  trait :bounding_box, debug: DEBUG
  include Clickable
  include Common
end

class Button < Chingu::GameObject
  trait :bounding_box, debug: DEBUG
  include Clickable
  include Common
end

def self.icon key = nil
  #TODO replace with yaml
  index, i = [:eye_open, :eye_closed, :left_arrow, :minus, :other2, :other3], 0
  @icons ||= Hash[Gosu::Image.load_tiles($window, File.expand_path('./media/gui/icons.png'), 16, 16, true).map { |im|
    [index[i] ? index[(i += 1)-1] : :blah, im]
  }]
  if key.nil? then @icons else @icons[key] end
end
end
