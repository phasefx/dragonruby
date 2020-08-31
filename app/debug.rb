def debug(args)
  debug_keys(args) if $debug
  case $debug_state
  when :paused
    # no args.state.game.tick
  else
    args.state.solids = []
    args.state.sprites = []
    args.state.primitives = []
    args.state.labels = []
    args.state.lines = []
    args.state.borders = []
    yield # call the passed block, and then keep going
    $debug_state = :paused if $debug_state == :step
  end
  args.outputs.solids << args.state.solids
  args.outputs.sprites << args.state.sprites
  args.outputs.primitives << args.state.primitives
  args.outputs.labels << args.state.labels
  args.outputs.lines << args.state.lines
  args.outputs.borders << args.state.borders
end

def debug_keys args
  if args.inputs.keyboard.key_down.eight
    $debug_state = :paused
    puts 'paused'
  end
  if args.inputs.keyboard.key_down.nine
    $debug_state = :program_running
    puts 'unpaused'
  end
  if args.inputs.keyboard.key_down.zero
    $debug_state = :step
    puts 'step'
  end
end
