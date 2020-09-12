# frozen_string_literal: true

# Input methods
module Input
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/MethodLength
  def self.meta_input(keymaps, inputs)
    intents = []
    down_keys = inputs.keyboard.key_down.truthy_keys
    down_keys.each do |truth|
      intents << 'toggle_fps' if keymaps[:toggle_fps].include?(truth)
      intents << 'exit' if keymaps[:exit].include?(truth)
      intents << 'reset' if keymaps[:reset].include?(truth)
      intents << 'save'  if keymaps[:save].include?(truth)
      intents << 'load' if keymaps[:load].include?(truth)
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
  def self.player_input(keymaps, inputs)
    intents = []
    down_keys = inputs.keyboard.key_down.truthy_keys
    held_keys = inputs.keyboard.key_held.truthy_keys
    down_keys.each do |truth|
      intents << 'start_left' if keymaps[:left].include?(truth)
      intents << 'start_right' if keymaps[:right].include?(truth)
      intents << 'start_up' if keymaps[:up].include?(truth)
      intents << 'start_down' if keymaps[:down].include?(truth)
    end
    held_keys.each do |truth|
      intents << 'move_left' if keymaps[:left].include?(truth)
      intents << 'move_right' if keymaps[:right].include?(truth)
      intents << 'move_up' if keymaps[:up].include?(truth)
      intents << 'move_down' if keymaps[:down].include?(truth)
    end
    puts intents if intents.length.positive?
    intents
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize
end
