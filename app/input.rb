# frozen_string_literal: true

def meta_input(inputs)
  intents = []
  intents << 'toggle_fps' if inputs.keyboard.space
  intents << 'exit' if inputs.keyboard.escape
  intents << 'reset' if inputs.keyboard.r
  intents << 'save'  if inputs.keyboard.s
  intents << 'load' if inputs.keyboard.l
  puts intents if intents.length.positive?
  intents
end

def player_input(inputs)
  intents = []
  puts intents if intents.length.positive?
  intents
end
