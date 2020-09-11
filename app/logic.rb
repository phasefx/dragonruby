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

def wrap(value, lower_bound, upper_bound)
  lower_bound, upper_bound = upper_bound, lower_bound if lower_bound > upper_bound
  return upper_bound if value < lower_bound
  return lower_bound if value > upper_bound

  value
end

def bound(value, lower_bound, upper_bound)
  lower_bound, upper_bound = upper_bound, lower_bound if lower_bound > upper_bound
  return lower_bound if value < lower_bound
  return upper_bound if value > upper_bound

  value
end

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/PerceivedComplexity
# rubocop:disable Metrics/CyclomaticComplexity
def game_logic(state, intents)
  gs = state.game
  gs[:theta] = wrap(gs[:theta] + 1, 0, 360)
  gs[:player][:coord] = [200 * Math.cos(gs[:theta].to_radians), 200 * Math.sin(gs[:theta].to_radians)]
  gs[:player][:coord].x -= 1 if intents.include?('move_left') || intents.include?('start_left')
  gs[:player][:coord].x += 1 if intents.include?('move_right') || intents.include?('start_right')
  gs[:player][:coord].y -= 1 if intents.include?('move_up') || intents.include?('start_up')
  gs[:player][:coord].y += 1 if intents.include?('move_down') || intents.include?('start_down')
  puts gs[:player] if intents.length.positive?
  gs
end
# rubocop:enable Metrics/CyclomaticComplexity
# rubocop:enable Metrics/PerceivedComplexity
# rubocop:enable Metrics/AbcSize
