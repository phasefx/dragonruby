$debug = true
$debug_state = :program_running

TEXT_HEIGHT = $gtk.calcstringbox("H")[1]
INITIAL_GRID_SIZE = 8 # for the 64x64 lowrezjam, this would give us a grid of 8x8 cells

require 'app/game.rb'
require 'app/debug.rb'

def tick args
  args.state.game ||= Game.new args
  debug args do
    args.state.game.tick
  end
end
