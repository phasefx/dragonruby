# frozen_string_literal: true

# Input methods
module FlightInput
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/MethodLength
  def self.meta_input(inputs, keymaps)
    intents = []
    down_keys = inputs.keyboard.key_down.truthy_keys
    down_keys.each do |truth|
      intents << 'toggle_fps' if keymaps[:Flight][:toggle_fps].include?(truth)
      intents << 'exit' if keymaps[:Flight][:exit].include?(truth)
      intents << 'reset' if keymaps[:Flight][:reset].include?(truth)
      intents << 'save'  if keymaps[:Flight][:save].include?(truth)
      intents << 'load' if keymaps[:Flight][:load].include?(truth)
    end
    puts intents if intents.length.positive?
    intents
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Metrics/CyclomaticComplexity
  def self.player_input(inputs, keymaps, mousemaps)
    intents = []
    down_keys = inputs.keyboard.key_down.truthy_keys
    held_keys = inputs.keyboard.key_held.truthy_keys
    # there aren't actually used currently but are an early example of what I'm going for
    down_keys.each do |truth|
      intents << 'start_left' if keymaps[:Flight][:left].include?(truth)
      intents << 'start_right' if keymaps[:Flight][:right].include?(truth)
      intents << 'start_up' if keymaps[:Flight][:up].include?(truth)
      intents << 'start_down' if keymaps[:Flight][:down].include?(truth)
    end
    held_keys.each do |truth|
      intents << 'move_left' if keymaps[:Flight][:left].include?(truth)
      intents << 'move_right' if keymaps[:Flight][:right].include?(truth)
      intents << 'move_up' if keymaps[:Flight][:up].include?(truth)
      intents << 'move_down' if keymaps[:Flight][:down].include?(truth)
    end
    # the mouse input, however, is being used at the moment
    intents << 'standard_action' if inputs.mouse.down && inputs.mouse.send(mousemaps[:Flight][:standard_action][0])
    intents << 'alternate_action' if inputs.mouse.down && inputs.mouse.send(mousemaps[:Flight][:alternate_action][0])
    intents << 'mouse_up' if inputs.mouse.up
    puts intents if intents.length.positive?
    intents
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize
end
