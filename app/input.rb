# frozen_string_literal: true

def input_with_side_effects(gtk, inputs, game_state)
  exit if inputs.keyboard.escape
  gtk.gtk.reset if inputs.keyboard.r
  save gtk, game_state if inputs.keyboard.s
  parsed_state = load gtk if inputs.keyboard.l
  return parsed_state if parsed_state

  gtk.state
end

def input(inputs)
  intents = []
  intents << 'toggle_fps' if inputs.keyboard.space
  puts intents if intents.length.positive?
  intents
end
