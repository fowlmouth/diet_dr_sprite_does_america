#!/usr/bin/env ruby
%w[
  gosu
  chingu
  texplay
  pry
].each { |l| require l }
$: << '.'
%w[
  editing-state
  loading-state
  ghetto-animation
  anim-preview
  sprite-part
  zorder
  grid
  gui/textfield
  gui/cursor
  gui/button
].each { |l| require "lib/#{l}" }

module SpriteEdit
class Window < Chingu::Window
  
  def initialize
    super 640, 480, false
    self.factor = 4
    self.input = { escape: :exit }# left_mouse_button: :lclick }
    retrofy
    
    #push_game_state LoadingState
    push_game_state EditingState.new(file: (ARGV[0] or './media/boxtest.yml'))
  end
  
  def update
    super
    self.caption = "Mouse @ #{mouse_x}/#{mouse_y}"
  end
  
end
end

SpriteEdit::Window.new.show
