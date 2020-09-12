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
    p = Game.deep_clone point
    proposed_theta = wrap(p[:theta] + 1, 0, 360)
    proposed_coord = equation.call(proposed_theta)
    p[:theta] = proposed_theta unless player[:visible] && proposed_coord.intersect_rect?(player[:rect], 0)
    p[:coord] = proposed_coord
    p
  end

  # rubocop:disable Metrics/AbcSize
  # _rubocop:disable Metrics/PerceivedComplexity
  # _rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/MethodLength
  def self.game_logic(state, mouse, intents)
    gs = Game.deep_clone state.game
    player = gs[:actors][:player]
    player = player_logic(player, mouse, intents)

    equations = [
      ->(t) { [200 * cos(3, t), 200 * sin(2, t)] },
      ->(t) { [200 * cos(1, t), 200 * sin(1, t)] },
      ->(t) { [200 * cos(2, t), 200 * sin(3, t)] }
    ]

    gs[:actors][:triangles].each_with_index do |triangle, t_idx|
      triangle[:points].each_with_index do |point, p_idx|
        gs[:actors][:triangles][t_idx][:points][p_idx] = test_and_move_point(
          point,
          equations[p_idx],
          player
        )
      end
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
    p = Game.deep_clone player
    p[:size] = bound(player[:size] + 10, 1, 100)
    p[:coord] = mouse.position if intents.include?('standard_action')
    p[:visible] = true         if intents.include?('standard_action')
    p[:size] = 1               if intents.include?('standard_action')
    p[:visible] = false        if intents.include?('mouse_up')
    p[:size] = 1               if intents.include?('mouse_up')
    p[:rect] = [
      p[:coord].x - p[:size].half,
      p[:coord].y - p[:size].half,
      p[:size], p[:size]
    ]

    p
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize
end
