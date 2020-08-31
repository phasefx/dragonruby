#
#   Working Title:
#
#     Geomancer
#
#   Constraints:
#
#     LOWREZJAM2020 calls for 64x64 pixels or less.  I think scaling the pixels up into fat pixels is okay.
#     However, now that LOWREZJAM2020 is over (and I missed it), I'm going to relax the constraints. :D
#
#   Some ideas:
#
#     * Rogue-like game where your magic is drawn from and manipulates the geography around you.
#       * Match-3 tile-swap, destroys terrain, damages enemies on terrain
#       * Rotate adjacent tiles
#       * Control terrain elevation (consider sea-level for draining/filling bodies of water)
#       * Tower-Defense mechanics (because, why not?:)
#
#   Game State
#
#     :default
#
#       Game comprises an 12x12 view grid into a larger grid space of tiles and sprites
#       key 6 changes state to :paint
#       key 7 changes state to :palette
#
#     :paint
#
#       More like Stamp mode for building maps.
#       Arrow keys move cursor which highlights active grid cell
#       Shift+[1-5] assigns the current tile to a numbered stamp slot
#       [1-5] stamps the tile associated with the stamp slot to the active gid cell
#       Alt+[1-5] toggles the "layer" being manipulated
#       Escape changes state to :default
#       key 7 changes state to :palette
#
#     :palette
#
#       A read-only grid of all tiles available to paint with
#       Arrow keys move cursor which highlights active grid cell
#       Shift+[1-5] assigns the current tile to a numbered stamp slot
#       Escape changes state to :paint
#       key 6 changes state to :paint
#

$debug = true
$debug_state = :program_running

TEXT_HEIGHT = $gtk.calcstringbox('H')[1]
INITIAL_GRID_SIZE = 12 # for the 64x64 lowrezjam, 8 would give us an 8x8 grid of cells (containing sprites of 8x8 pixels)
KEY_HELD_DELAY = 30 # ticks; DR tries for 60 ticks per second

require 'app/debug.rb'
require 'app/common_keys.rb'
require 'app/default_keys.rb'
require 'app/paint_keys.rb'
require 'app/palette_keys.rb'
require 'app/grid.rb'
require 'app/game.rb'

######
# DragonRuby GTK entry point for our code
def tick args
  args.state.game ||= Game.new args
  debug args do
    args.state.game.tick
  end
end
