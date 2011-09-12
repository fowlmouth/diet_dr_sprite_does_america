#!/usr/bin/env ruby
module Gui
class TextField < Chingu::Text
  attr_reader :input
  trait :bounding_box
  
  def initialize options = {}
    super options
    @input = Gosu::TextInput.new
    @input.text = @text
    
    @caret_color = options[:caret_color]
  end
  
  def update
    self.text = @input.text
  end
  
  #also handles move_caret()
  def select sel_x
    $window.text_input = @input
    @active = true 
    sel_x /= self.factor_x
    1.upto(@input.text.length) do |i|
      if sel_x < self.x + @gosu_font.text_width(text[0...i])
        puts i, @gosu_font.text_width(text[0...i])
        @input.caret_pos = @input.selection_start = i - 1
        return
      end
    end
    @input.caret_pos = @input.selection_start = @input.text.length
  end
  
  def unselect
    if $window.text_input == @input
      $window.text_input = nil
      @active = false
    end
  end
  
  def draw
    super
    if @active
      if @caret_color
        #cposx = (@x * self.factor_x) + @gosu_font.text_width(self.text[0...@input.caret_pos])
        cposx = @x + (@gosu_font.text_width(self.text[0 ... @input.caret_pos]) * self.factor_x)
        cselx = @x + (@gosu_font.text_width(self.text[0...@input.selection_start]) * self.factor_x)
        h = @gosu_font.height * self.factor_y
        $window.draw_quad(cselx, self.y,  @caret_color,
                          cposx, self.y,  @caret_color,
                          cselx, self.y+h, @caret_color,
                          cposx, self.y+h, @caret_color, 0)
        $window.draw_line(cposx, self.y,   @caret_color,
                          cposx, self.y+h, @caret_color, 0)
      end
    end
  end
end
end
