# frozen_string_literal: true

require 'app/input.rb'
require 'app/logic.rb'
require 'app/render.rb'
require 'app/load_save.rb'

# This is our entry-point into DragonRuby Game Toolkit
# rubocop:disable Metrics/AbcSize
def tick(gtk)
  gtk.state.game ||= init gtk
  gtk.state = input_with_side_effects gtk, gtk.inputs, gtk.state.game
  player_intents = input gtk.inputs
  gtk.state.game = logic gtk.state.game, player_intents
  gtk.outputs.primitives << render(gtk.state.game, gtk)
end
# rubocop:enable Metrics/AbcSize

def init(gtk)
  # some side-effects...
  gtk.gtk.set_window_title(':-)')
  # and what we're really after, the game model/state
  {
    player: {
    },
    show_fps: true
  }
end
