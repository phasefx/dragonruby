# frozen_string_literal: true

# game logic
module Logic
  def self.toggle_fps(gtk)
    gtk.state.game[:show_fps] = !gtk.state.game[:show_fps]
  end

  def self.meta_intent_handler(gtk, intents)
    # gtk.state.game (more for config options than game logic)
    toggle_fps(gtk) if intents.include?('toggle_fps')

    # side-effects
    exit if intents.include?('exit')

    # gtk.gtk.reset if intents.include?('reset')
    # this messes up when we re-assign gtk.state
    # (because it itself is implemented via a flag in gtk.state)
    # so we'll call later at the end of the tick

    State.save gtk, gtk.state if intents.include?('save')

    # gtk.state
    parsed_state = State.load gtk if intents.include?('load')
    return parsed_state if parsed_state

    gtk.state
  end

  def self.wrap(value, lower_bound, upper_bound)
    lower_bound, upper_bound = upper_bound, lower_bound if lower_bound > upper_bound
    return upper_bound if value < lower_bound
    return lower_bound if value > upper_bound

    value
  end

  def self.bound(value, lower_bound, upper_bound)
    lower_bound, upper_bound = upper_bound, lower_bound if lower_bound > upper_bound
    return lower_bound if value < lower_bound
    return upper_bound if value > upper_bound

    value
  end

  def self.cos(coefficient, theta)
    Math.cos(coefficient * theta.to_radians)
  end

  def self.sin(coefficient, theta)
    Math.sin(coefficient * theta.to_radians)
  end

  # rubocop:disable Metrics/AbcSize
  # _rubocop:disable Metrics/PerceivedComplexity
  # _rubocop:disable Metrics/CyclomaticComplexity
  # _rubocop:disable Metrics/MethodLength
  def self.game_logic(state, _intents)
    gs = state.game
    gs[:theta] = wrap(gs[:theta] + 1, 0, 360)
    gs[:actors][:triangles][0][:points][0][:coord] = [200 * cos(3, gs[:theta]), 200 * sin(2, gs[:theta])]
    gs[:actors][:triangles][0][:points][1][:coord] = [200 * cos(1, gs[:theta]), 200 * sin(1, gs[:theta])]
    gs[:actors][:triangles][0][:points][2][:coord] = [200 * cos(2, gs[:theta]), 200 * sin(3, gs[:theta])]
    gs
  end
  # _rubocop:enable Metrics/MethodLength
  # _rubocop:enable Metrics/CyclomaticComplexity
  # _rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/AbcSize
end
