# frozen_string_literal: true

# saving and loading game state
module State
  # Saves the state of the game in a text file called game_state.txt.
  def self.save(gtk, state)
    gtk.gtk.serialize_state('game_state.txt', state)
    puts state
  end

  # Loads the game state from the game_state.txt text file.
  def self.load(gtk)
    gtk.gtk.deserialize_state('game_state.txt')
  end
end
