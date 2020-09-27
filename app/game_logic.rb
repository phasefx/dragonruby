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

  def self.game_logic(state, _intents)
    gs = Game.deep_clone state.game

    gs[:actors][:blocks].each do |b|
      if gs[:mouse][:any_mouse_down] && gs[:mouse][:position].intersect_rect?(b[:rect])
        b[:direction].x = if gs[:mouse][:position].x > b[:rect].x + b[:rect].w.half
                            -2 * b[:direction].x.abs
                          else
                            2 * b[:direction].x.abs
                          end
        b[:direction].y = if gs[:mouse][:position].y > b[:rect].y + b[:rect].h.half
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

    gs
  end
end
