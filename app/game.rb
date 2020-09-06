class Game
  def initialize(args = nil)
    wrap_gtk_args(args) if args;
    @gtk_args.gtk.set_window_title ':-)' if @gtk_args
  end

  # someday we may need to do this every GTK tick
  def wrap_gtk_args(args)
    @gtk_args = args
    @gtk_inputs = args.inputs
    @gtk_outputs = args.state # args.outputs (we get here eventually with debug.rb)
    @gtk_state = args.state
    @gtk_grid = args.grid
    @gtk_kb = @gtk_inputs.keyboard
    @gtk_mouse = @gtk_inputs.mouse
  end

  def tick
    @gtk_outputs.labels << [0, TEXT_HEIGHT, "FPS #{@gtk_args.gtk.current_framerate.floor}  Tick #{@gtk_args.tick_count}"]
  end
end
