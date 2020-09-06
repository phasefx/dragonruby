$debug = true
$debug_state = :program_running

TEXT_HEIGHT = $gtk.calcstringbox('H')[1]

require 'app/game.rb'
require 'app/debug.rb'

def tick(args)
  $game ||= Game.new args
  debug args do
    $game.tick
  end
end
