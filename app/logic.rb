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

  def self.test_and_move_point(point, equation, player)
    proposed_theta = wrap(point[:theta] + 1, 0, 360)
    proposed_coord = equation.call(proposed_theta)
    point[:theta] = proposed_theta unless player[:visible] && proposed_coord.intersect_rect?(player[:rect], 0)
    point[:coord] = proposed_coord
    point
  end

  # rubocop:disable Metrics/AbcSize
  # _rubocop:disable Metrics/PerceivedComplexity
  # _rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/MethodLength
  def self.game_logic(state, mouse, intents)
    gs = state.game
    player = gs[:actors][:player]
    player = player_logic(player, mouse, intents)

    equations = [
      ->(t) { [200 * cos(3, t), 200 * sin(2, t)] },
      ->(t) { [200 * cos(1, t), 200 * sin(1, t)] },
      ->(t) { [200 * cos(2, t), 200 * sin(3, t)] }
    ]

    gs[:actors][:triangles][0][:points].each_with_index do |point, idx|
      test_and_move_point(point, equations[idx], player)
    end

    gs[:actors][:player] = player
    gs
  end
  # rubocop:enable Metrics/MethodLength
  # _rubocop:enable Metrics/CyclomaticComplexity
  # _rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def self.player_logic(player, mouse, intents)
    player[:size] = bound(player[:size] + 10, 1, 100)
    player[:coord] = mouse.position if intents.include?('standard_action')
    player[:visible] = true         if intents.include?('standard_action')
    player[:size] = 1               if intents.include?('standard_action')
    player[:visible] = false        if intents.include?('mouse_up')
    player[:size] = 1               if intents.include?('mouse_up')
    player[:rect] = [
      player[:coord].x - player[:size].half,
      player[:coord].y - player[:size].half,
      player[:size], player[:size]
    ]

    player
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize
end
