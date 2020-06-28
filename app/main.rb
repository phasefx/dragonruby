$gtk.set_window_title "PhaseFX"

require 'app/Physics.rb'
require 'app/Actor.rb'
require 'app/Audio.rb'
require 'app/Input.rb'
require 'app/Level.rb'
require 'app/Logic.rb'
require 'app/Render.rb'
require 'app/Game.rb'

###############################################################################
# main

def assert(condition, message = nil)
  fail "Assertion failed: #{message}" if !condition
end

def tick args
  #trace!($gtk)
  args.state.game ||= Game.new args
  args.state.game.tick
  #puts "60 ticks..." if args.state.tick_count % 60 == 0
end # of tick
