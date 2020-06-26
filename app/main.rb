$gtk.reset
$gtk.set_window_title "PhaseFX"

require 'app/Game.rb'

###############################################################################
# main

def tick args
  args.state.game ||= Game.new args
  args.state.game.tick
  #puts "60 ticks..." if args.state.tick_count % 60 == 0
  $gtk.reset seed: rand(Time.now.sec) if args.state[:reset_desired?]
end # of tick
