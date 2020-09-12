# frozen_string_literal: true

require 'app/input.rb'
require 'app/logic.rb'
require 'app/render.rb'
require 'app/load_save.rb'

# This is our entry-point into DragonRuby Game Toolkit
#
#   def tick(gtk) is called roughly 60 times a second
#
#   gtk is traditionally called args in GTK samples
#   $gtk is global reference to the engine that we can
#   also get to with gtk.gtk
#
#   gtk.state is meant for storing things between ticks
#
#     It has some OpenStruct-like magic for vivicating
#     intermediate data structures, and gets dumped
#     into the exceptions/ folder for said exceptions.
#
#   gtk.state.game is where I'm storing the game model
#
#   gtk.inputs is where we get our keyboard, mouse, and
#   gamepad input
#
#   gtk.outputs is where we put our desired output. With
#   some exceptions, it's cleared out automatically for
#   every tick
#
#   In general, I'm trying to distance input (intent)
#   from behavior (state change) and keep the pipeline
#   purely functional, but there are some things (usually
#   calls to gtk.gtk) that break that.  I'll try to put
#   those things into def meta_intent_handler

# rubocop:disable Metrics/AbcSize
def tick(gtk)
  gtk.state.game ||= Game.init gtk
  meta_intents = Input.meta_input gtk.state.game[:keymaps], gtk.inputs
  player_intents = Input.player_input gtk.state.game[:keymaps], gtk.state.game[:mousemaps], gtk.inputs
  gtk.state = Logic.meta_intent_handler gtk, meta_intents
  gtk.state.game = Logic.game_logic gtk.state, gtk.inputs.mouse, player_intents
  gtk.outputs.primitives << Output.render(gtk.state.game, gtk)
  gtk.gtk.reset if meta_intents.include?('reset')
end
# rubocop:enable Metrics/AbcSize

# housekeeping
module Game
  # rubocop:disable Security/Eval
  def self.deep_clone(obj)
    # using $gtk is just too convenient to pass up here
    eval $gtk.serialize_state obj
  end
  # rubocop:enable Security/Eval

  # rubocop:disable Metrics/MethodLength
  def self.init(gtk)
    # some side-effects...
    gtk.gtk.set_window_title(':-)')
    gtk.grid.origin_center!
    # and what we're really after, the game model/state
    game = {
      actors: {
        player: { coord: [0, 0], visible: false, size: 1 },
        triangles: [
          {
            points: [
              { coord: [0, 0], offset: [0, 0], theta: 0, equation: 0 },
              { coord: [0, 0], offset: [0, 0], theta: 0, equation: 1 },
              { coord: [0, 0], offset: [0, 0], theta: 0, equation: 2 }
            ]
          },
          {
            points: [
              { coord: [0, 0], offset: [0, 0], theta: 15, equation: 0 },
              { coord: [0, 0], offset: [0, 0], theta: 15, equation: 1 },
              { coord: [0, 0], offset: [0, 0], theta: 15, equation: 2 }
            ]
          },
          {
            points: [
              { coord: [0, 0], offset: [0, 0], theta: 30, equation: 0 },
              { coord: [0, 0], offset: [0, 0], theta: 30, equation: 1 },
              { coord: [0, 0], offset: [0, 0], theta: 30, equation: 2 }
            ]
          },
          {
            points: [
              { coord: [0, 0], offset: [0, 0], theta: 90, equation: 0 },
              { coord: [0, 0], offset: [0, 0], theta: 90, equation: 1 },
              { coord: [0, 0], offset: [0, 0], theta: 90, equation: 2 }
            ]
          }
        ]
      },
      show_fps: true,
      mousemaps: {
        standard_action: %i[button_left]
      },
      keymaps: {
        left: %i[left a],
        right: %i[right d],
        up: %i[up w],
        down: %i[down s],
        toggle_fps: %i[space],
        exit: %i[escape],
        reset: %i[r],
        load: %i[l],
        save: %i[m]
      }
    }
    puts game
    game
  end
  # rubocop:enable Metrics/MethodLength
end
