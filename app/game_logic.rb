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
    gtk.state.game[:desire_next_level] = true if intents.include?('next_level')

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
    if p[:grow_crosshair] # click vs hold => temporary increased area vs smaller sustained area
      p[:size] = bound(player[:size] + 10, 1, 200)
      p[:grow_crosshair] = false if p[:size] >= 200
    else
      p[:size] = bound(player[:size] - 10, 100, 200)
    end
    p[:coord] = mouse[:position]
    p[:became_visible] = false
    p[:became_visible] = true  if intents.include?('standard_action')
    p[:grow_crosshair] = true  if intents.include?('standard_action')
    p[:visible] = true         if intents.include?('standard_action')
    p[:size] = 50              if intents.include?('standard_action')
    p[:click_count] += 1       if intents.include?('standard_action')
    p[:visible] = false        if intents.include?('mouse_up')
    p[:size] = 50              if intents.include?('mouse_up')
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

    gs[:timer] = bound(gs[:timer] - 1, 0, 20) if state.tick_count.mod(60).zero?
    gs[:game_over] = true unless gs[:timer].positive?

    player[:hit_target] = false
    gs[:actors][:targets].each do |t|
      next if t[:caught]

      coord = [t[:label].x, t[:label].y]
      next unless player[:visible] && coord.intersect_rect?(player[:rect], 10)

      player[:hit_target] = true
      t[:caught] = true
      player[:score] += 1 unless gs[:game_over]
      t[:label][2] = 'o'
      player[:total_targets_caught] += 1
    end

    targets_caught_this_level = gs[:actors][:targets].select { |t| t[:caught] }.length
    targets_this_level = gs[:actors][:targets].length
    if targets_caught_this_level >= targets_this_level
      gs[:desire_next_level_at] = $gtk.args.tick_count if gs[:desire_next_level_at].nil?
      if $gtk.args.tick_count - gs[:desire_next_level_at] >= 30
        gs[:desire_next_level] = true
        gs[:desire_next_level_at] = nil
      end
    end

    gs[:actors][:blocks].each_with_index do |b, idx|
      actor_block = b
      volatile_block = state.volatile[:blocks][idx]
      # repulse blocks around active reticule
      if player[:visible] && volatile_block.intersect_rect?(player[:rect], 0)
        # magnitude = player[:size] < 100 ? 2.5 : 2 # slight boost with click vs hold
        magnitude = 2
        actor_block[:direction].x = if player[:coord].x > volatile_block.x + volatile_block.w.half
                                      -magnitude * actor_block[:direction].x.abs
                                    else
                                      magnitude * actor_block[:direction].x.abs
                                    end
        actor_block[:direction].y = if player[:coord].y > volatile_block.y + volatile_block.h.half
                                      -magnitude * actor_block[:direction].y.abs
                                    else
                                      magnitude * actor_block[:direction].y.abs
                                    end
      end
      actor_block[:direction].x = throttle(actor_block[:direction].x)
      actor_block[:direction].y = throttle(actor_block[:direction].y)
      if gs[:game_over]
        volatile_block.x = bound(
          volatile_block.x + actor_block[:direction].x,
          $gtk.args.grid.left - 200,
          $gtk.args.grid.right + 200
        )
        volatile_block.y = bound(
          volatile_block.y + actor_block[:direction].y,
          $gtk.args.grid.bottom - 200,
          $gtk.args.grid.top + 200
        )
      else
        volatile_block.x = wrap(
          volatile_block.x + actor_block[:direction].x,
          $gtk.args.grid.left - 200,
          $gtk.args.grid.right + 200
        )
        volatile_block.y = wrap(
          volatile_block.y + actor_block[:direction].y,
          $gtk.args.grid.bottom - 200,
          $gtk.args.grid.top + 200
        )
      end
    end

    gs[:actors][:player] = player
    gs
  end
end
