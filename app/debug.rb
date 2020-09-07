# frozen_string_literal: true

def clear_fake_outputs(args)
  args.state.solids = []
  args.state.sprites = []
  args.state.primitives = []
  args.state.labels = []
  args.state.lines = []
  args.state.borders = []
end

# rubocop: disable Metrics/AbcSize
def populate_outputs(args)
  args.outputs.solids << args.state.solids
  args.outputs.sprites << args.state.sprites
  args.outputs.primitives << args.state.primitives
  args.outputs.labels << args.state.labels
  args.outputs.lines << args.state.lines
  args.outputs.borders << args.state.borders
end
# rubocop: enable Metrics/AbcSize

def debug(args)
  debug_keys(args) if $debug
  case $debug_state
  when :paused
    # no $game.tick
  else
    clear_fake_outputs(args)
    yield # call the passed block, and then keep going
    $debug_state = :paused if $debug_state == :step
  end
  populate_outputs(args)
end

def debug_keys(args)
  $debug_state = :paused if args.inputs.keyboard.key_down.eight
  $debug_state = :program_running if args.inputs.keyboard.key_down.nine
  $debug_state = :step if args.inputs.keyboard.key_down.zero
  puts $debug_state.to_s unless $debug_state == :program_running
end
