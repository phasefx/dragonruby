# frozen_string_literal: true

def toggle_fps(gtk)
  gtk.state.game[:show_fps] = !gtk.state.game[:show_fps]
end

def meta_intent_handler(gtk, intents)
  # gtk.state.game (more for config options than game logic)
  toggle_fps(gtk) if intents.include?('toggle_fps')

  # side-effects
  exit if intents.include?('exit')

  # gtk.gtk.reset if intents.include?('reset')
  # this messes up when we re-assign gtk.state
  # (because it itself is implemented via a flag in gtk.state)
  # so we'll call later at the end of the tick

  save gtk, gtk.state if intents.include?('save')

  # gtk.state
  parsed_state = load gtk if intents.include?('load')
  return parsed_state if parsed_state

  gtk.state
end

# rubocop:disable Metrics/AbcSize
def game_logic(state, intents)
  gs = state.game
  gs[:player][:x] -= 1 if intents.include?('move_left')
  gs[:player][:x] += 1 if intents.include?('move_right')
  gs[:player][:y] -= 1 if intents.include?('move_up')
  gs[:player][:y] += 1 if intents.include?('move_down')
  puts gs[:player] if intents.length.positive?
  gs
end
# rubocop:enable Metrics/AbcSize
