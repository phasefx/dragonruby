class Game
  attr_accessor :state, :palette_coords

  include DefaultKeys
  include PaintKeys
  include PaletteKeys
  include Grid

  def initialize args
    # GTK bits
    $gtk.set_window_title 'Geomancer'
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

    # for the palette grid
    @palette_coords ||= [0,0]

    set_state(:default)
  end

  def serialize
    { :state => @state }
  end

  def inspect
    serialize.to_s
  end

  def to_s
    serialize.to_s
  end

  def set_state state
    puts "state change from #{@state.nil? ? 'nil' : @state} to #{state.nil? ? 'nil' : state}"
    @state = state
  end

  ######
  # our main loop goes here
  def tick
    case @state
    when :default
      default_keys
      render_grid_borders
    when :paint
      paint_keys
      render_grid_borders
    when :palette
      palette_keys
      render_grid_borders
      render_tile_sheet
    end
    @gtk_outputs.labels << [0,TEXT_HEIGHT,"FPS #{@gtk_args.gtk.current_framerate.floor}  Tick #{@gtk_args.tick_count}"]
  end
end
