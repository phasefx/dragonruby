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

  ######
  # useful coordinate functions for mapping mouse x,y to cell h,v and vice versa

  def x2hpos x
    ax = x - @grid_offset[0]
    (ax/@grid_segment_size).floor
  end

  def y2vpos y
    ay = y - @grid_offset[1]
    (ay/@grid_segment_size).floor
  end

  def hpos2x hpos
    @grid_offset[0] + (@grid_segment_size * hpos)
  end

  def vpos2y vpos
    @grid_offset[1] + (@grid_segment_size * vpos)
  end

  ######
  # our main loop goes here
  def tick
    render_grid_borders # may turn these off during actual play
    @gtk_outputs.labels << [0,TEXT_HEIGHT,"FPS #{@gtk_args.gtk.current_framerate.floor}  Tick #{@gtk_args.tick_count}"]
  end
end
