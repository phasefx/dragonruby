# frozen_string_literal: true

# game logic
module GameLogic

  SPEED_THRESHOLD = 5 # if above this speed, start throttling

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

  def self.throttle(value)
    if value.abs > SPEED_THRESHOLD
      value += value.negative? ? 1 : -1
    end
    value
  end

  def self.player_logic(player, mouse, intents)
    p = Game.deep_clone player
    p[:size] = bound(player[:size] + 10, 1, 100)
    p[:coord] = mouse[:position]
    p[:became_visible] = false
    p[:became_visible] = true  if intents.include?('standard_action')
    p[:visible] = true         if intents.include?('standard_action')
    p[:size] = 1               if intents.include?('standard_action')
    p[:visible] = false        if intents.include?('mouse_up')
    p[:size] = 1               if intents.include?('mouse_up')
    p[:rect] = [
      p[:coord].x - p[:size].half,
      p[:coord].y - p[:size].half,
      p[:size], p[:size],
      GameOutput::TEXT
    ]

    p
  end

  def self.game_logic(state, intents)
    gs = Game.deep_clone state.game
    player = gs[:actors][:player]
    player = player_logic(player, gs[:mouse], intents)

    gs[:actors][:blocks].each do |b|
      if player[:visible] && b[:rect].intersect_rect?(player[:rect], 0)
        b[:direction].x = if player[:coord].x > b[:rect].x + b[:rect].w.half
                            -2 * b[:direction].x.abs
                          else
                            2 * b[:direction].x.abs
                          end
        b[:direction].y = if player[:coord].y > b[:rect].y + b[:rect].h.half
                            -2 * b[:direction].y.abs
                          else
                            2 * b[:direction].y.abs
                          end
      end
      b[:direction].x = throttle(b[:direction].x)
      b[:direction].y = throttle(b[:direction].y)
      b[:rect].x = wrap(
        b[:rect].x + b[:direction].x,
        $gtk.args.grid.left - 200,
        $gtk.args.grid.right + 200
      )
      b[:rect].y = wrap(
        b[:rect].y + b[:direction].y,
        $gtk.args.grid.bottom - 200,
        $gtk.args.grid.top + 200
      )
    end

    gs[:actors][:player] = player
    gs
  end
end
