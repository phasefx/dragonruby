# frozen_string_literal: true

# Input methods
module GameInput
  def self.meta_input(inputs, keymaps)
    intents = []
    down_keys = inputs.keyboard.key_down.truthy_keys
    down_keys.each do |truth|
      intents << 'toggle_fps' if keymaps[:Game][:toggle_fps].include?(truth)
      intents << 'exit' if keymaps[:Game][:exit].include?(truth)
      intents << 'reset' if keymaps[:Game][:reset].include?(truth)
      intents << 'save'  if keymaps[:Game][:save].include?(truth)
      intents << 'load' if keymaps[:Game][:load].include?(truth)
    end
    puts intents if intents.length.positive?
    intents
  end

  def self.player_input(inputs, keymaps, mousemaps)
    intents = []

    down_keys = inputs.keyboard.key_down.truthy_keys
    held_keys = inputs.keyboard.key_held.truthy_keys

    down_keys.each do |truth|
      intents << 'start_left' if keymaps[:Game][:left].include?(truth)
      intents << 'start_right' if keymaps[:Game][:right].include?(truth)
      intents << 'start_up' if keymaps[:Game][:up].include?(truth)
      intents << 'start_down' if keymaps[:Game][:down].include?(truth)
    end

    held_keys.each do |truth|
      intents << 'move_left' if keymaps[:Game][:left].include?(truth)
      intents << 'move_right' if keymaps[:Game][:right].include?(truth)
      intents << 'move_up' if keymaps[:Game][:up].include?(truth)
      intents << 'move_down' if keymaps[:Game][:down].include?(truth)
    end

    intents << 'standard_action' if inputs.mouse.down && inputs.mouse.send(mousemaps[:Game][:standard_action][0])
    intents << 'alternate_action' if inputs.mouse.down && inputs.mouse.send(mousemaps[:Game][:alternate_action][0])
    intents << 'mouse_up' if inputs.mouse.up
    intents << 'mouse_down' if inputs.mouse.down

    puts intents if intents.length.positive?
    intents
  end
end
