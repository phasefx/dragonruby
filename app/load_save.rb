# frozen_string_literal: true

# Saves the state of the game in a text file called game_state.txt.
def save(gtk, state)
  gtk.gtk.serialize_state('game_state.txt', state)
end

# Loads the game state from the game_state.txt text file.
def load(gtk)
  gtk.gtk.deserialize_state('game_state.txt')
end
