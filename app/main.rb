$debug = true
$debug_state = :program_running

TEXT_HEIGHT = $gtk.calcstringbox('H')[1]

require 'app/game.rb'
require 'app/debug.rb'

def tick(args)
  args.state.game ||= Game.new args
  debug args do
    args.state.game.tick
  end
end
