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
    self.factor = 3
    self.input = { escape: :exit }# left_mouse_button: :lclick }
    retrofy
    
    #push_game_state LoadingState
    push_game_state EditingState.new(file: './media/redchar.yml')
  end
  
end
end

SpriteEdit::Window.new.show
