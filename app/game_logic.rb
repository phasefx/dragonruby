# frozen_string_literal: true

# game logic
module GameLogic
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

  def self.game_logic(state, intents)
    gs = Game.deep_clone state.game
    gs[:buttons].each_with_index do |b,i|
      if intents.include?('standard_action') and gs[:mouse][:last_click].inside_rect? b
        puts "clicked #{i}"
      elsif state[:mouse][:position].inside_rect? b
        puts "hovered #{i}"
      else
        #b.merge({target: :border, r:168,g:168,b:168})
      end
    end
    gs
  end
end
