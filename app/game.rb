class Game
  def initialize args
    $gtk.set_window_title ':-)'
    @gtk_args = args
    @gtk_inputs = args.inputs
    @gtk_outputs = args.outputs
    @gtk_state = args.state
    @gtk_grid = args.grid
    @gtk_kb = @gtk_inputs.keyboard
    @gtk_mouse = @gtk_inputs.mouse
  end

  def tick
    @gtk_state.labels << [0,TEXT_HEIGHT,"FPS #{@gtk_args.gtk.current_framerate.floor}  Tick #{@gtk_args.tick_count}"]
  end
end

