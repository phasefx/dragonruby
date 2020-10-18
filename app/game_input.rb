# frozen_string_literal: true

# Input methods
module GameInput
  def self.meta_input(inputs, keymaps)
    intents = []
    down_keys = inputs.keyboard.key_down.truthy_keys
    down_keys.each do |truth|
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
      intents << 'button 0' if keymaps[:Game][:button0].include?(truth)
      intents << 'button 1' if keymaps[:Game][:button1].include?(truth)
      intents << 'button 2' if keymaps[:Game][:button2].include?(truth)
      intents << 'button 3' if keymaps[:Game][:button3].include?(truth)
      intents << 'button 4' if keymaps[:Game][:button4].include?(truth)
      intents << 'button 5' if keymaps[:Game][:button5].include?(truth)
      intents << 'button 6' if keymaps[:Game][:button6].include?(truth)
      intents << 'button 7' if keymaps[:Game][:button7].include?(truth)
      intents << 'button 8' if keymaps[:Game][:button8].include?(truth)
      intents << 'button 9' if keymaps[:Game][:button9].include?(truth)
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
