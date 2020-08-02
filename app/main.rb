$debug = true
$debug_state = :program_running

TEXT_HEIGHT = $gtk.calcstringbox("H")[1]
INITIAL_GRID_SIZE = 8 # for the 64x64 lowrezjam, this would give us a grid of 8x8 cells

require 'app/game.rb'
require 'app/debug.rb'

class Game
  def initialize args
    # GTK bits
    $gtk.set_window_title ':-)'
    @gtk_args = args
    @gtk_inputs = args.inputs
    @gtk_outputs = args.state # normally args.outputs, but we're doing some judo here for the debug loop
    @gtk_static_outputs = args.outputs # but for the .static_ variants, we don't need to do this
    @gtk_state = args.state
    @gtk_grid = args.grid
    @gtk_kb = @gtk_inputs.keyboard
    @gtk_mouse = @gtk_inputs.mouse

    # for the grid
    @lx = @gtk_grid.left
    @ux = @gtk_grid.right
    @ly = @gtk_grid.bottom
    @uy = @gtk_grid.top
    @w = @ux - @lx
    @h = @uy - @ly
    @grid_divisions = INITIAL_GRID_SIZE
    @cells = Array.new(@grid_divisions){Array.new(@grid_divisions,nil)}
    @grid_segment_size = (@h-10)/(@grid_divisions) # if we ever want to resize the grid during runtime, remember to move this
  end

  def render_grid_borders
    @grid_offset = [
      @lx + 290,
      @ly + 5
    ]
    @grid_divisions.times do |x|
      @grid_divisions.times do |y|
        @gtk_outputs.primitives << [
          @grid_offset[0] + (@grid_segment_size * x),
          @grid_offset[1] + (@grid_segment_size * y),
          @grid_segment_size,
          @grid_segment_size,
          0, 0, 0, 64
        ].border
      end
    end
  end

  def tick
    render_grid_borders # may turn these off during actual play
    @gtk_outputs.labels << [0,TEXT_HEIGHT,"FPS #{@gtk_args.gtk.current_framerate.floor}  Tick #{@gtk_args.tick_count}"]
  end
end

def tick args
  args.state.game ||= Game.new args
  debug args do
    args.state.game.tick
  end
end
