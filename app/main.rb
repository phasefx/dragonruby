=begin

  Working Title:

    Geomancer

  Constraints:

    LOWREZJAM2020 calls for 64x64 pixels or less.  I think scaling the pixels up into fat pixels is okay.

  Some ideas:

    * Rogue-like game where your magic is drawn from and manipulates the geography around you.
      * Match-3 tile-swap, destroys terrain, damages enemies on terrain
      * Rotate adjacent tiles
      * Control terrain elevation (consider sea-level for draining/filling bodies of water)

  Game State

    :default

      Game comprises an 8x8 view grid into a larger grid space of tiles and sprites
      key 6 changes state to :paint
      key 7 changes state to :palette

    :paint

      More like Stamp mode for building maps.
      Arrow keys move cursor which highlights active grid cell
      Shift+[1-5] assigns the current tile to a numbered stamp slot
      [1-5] stamps the tile associated with the stamp slot to the active gid cell
      Escape changes state to :default
      key 7 changes state to :palette

    :palette

      A read-only grid of all tiles available to paint with
      Arrow keys move cursor which highlights active grid cell
      Shift+[1-5] assigns the current tile to a numbered stamp slot
      Escape changes state to :paint
      key 6 changes state to :paint

=end

$debug = true
$debug_state = :program_running

TEXT_HEIGHT = $gtk.calcstringbox("H")[1]
INITIAL_GRID_SIZE = 8 # for the 64x64 lowrezjam, this would give us a grid of 8x8 cells

require 'app/game.rb'
require 'app/debug.rb'

######
# DragonRuby GTK entry point for our code
def tick args
  args.state.game ||= Game.new args
  debug args do
    args.state.game.tick
  end
end
