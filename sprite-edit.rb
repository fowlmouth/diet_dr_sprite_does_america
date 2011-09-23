#!/usr/bin/env ruby
%w[
  gosu
  chingu
  texplay
  ostruct
  pry
].each { |l| require l }
DEBUG = true
#$:.unshift File.dirname(__FILE__)
%w[
  main-window
  gui/frame-options
  gui/layer-options
  gui/textfield
  gui/cursor
  gui/button
  editing-state
  frame-set
  loading-state
  ghetto-animation
  anim-preview
  sprite-part
  zorder
  grid
].each { |l| require_relative "./lib/#{l}" }

Settings = OpenStruct.new \
  resolution: [1024, 640],
  default_file: './media/test/boxtest.yml'
  

#check out my awesome debugging thing, im cool huh :)
$- = Module.new {
  @last_str = nil
  
  def self.out str
    return if !DEBUG || str == @last_str
    @last_str = str
    puts str
  end
}

SpriteEdit::Window.new.show
