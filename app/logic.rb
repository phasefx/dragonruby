# frozen_string_literal: true

def logic(state, intents)
  state[:show_fps] = !state[:show_fps] if intents.include?('toggle_fps')
  state
end
