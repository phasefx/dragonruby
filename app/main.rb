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

#set_trace_func proc { |event, file, line, id, binding, classname|
#    printf "%8s %s:%-2d %10s %8s\n", event, file, line, id, classname
#}

def tick args
  #trace!($gtk)
  args.state.game ||= Game.new args
  args.state.game.tick
  #puts "60 ticks..." if args.state.tick_count % 60 == 0
end # of tick
