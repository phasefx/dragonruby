# frozen_string_literal: true

require 'app/flight_input.rb'
require 'app/flight_logic.rb'
require 'app/flight_render.rb'
require 'app/editor_input.rb'
require 'app/editor_logic.rb'
require 'app/editor_render.rb'
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
  gtk.state.game = Game.next_level gtk.state.game unless gtk.state.game[:actors]
  gtk.state.game = Game.next_level gtk.state.game if gtk.state.game[:actors][:player][:winner]
  input = Kernel.const_get("#{gtk.state.game[:scene]}Input")
  logic = Kernel.const_get("#{gtk.state.game[:scene]}Logic")
  output = Kernel.const_get("#{gtk.state.game[:scene]}Output")
  meta_intents = input.meta_input gtk.state.game[:keymaps], gtk.inputs
  player_intents = input.player_input gtk.state.game[:keymaps], gtk.state.game[:mousemaps], gtk.inputs
  gtk.state = logic.meta_intent_handler gtk, meta_intents
  gtk.state.game = logic.game_logic gtk.state, gtk.inputs.mouse, player_intents
  gtk.outputs.primitives << output.render(gtk.state.game, gtk)
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

  def self.v_add(*vectors)
    sum = []
    vectors.each do |v|
      v.each_with_index do |e, i|
        sum[i] = 0 if sum[i].nil?
        sum[i] += e
      end
    end
    sum
  end

  def self.next_level(game)
    return game if game[:current_level] == game[:levels].length - 1

    gs = deep_clone game
    gs[:current_level] += 1
    gs[:actors] = deep_clone gs[:levels][gs[:current_level]]
    gs
  end

  def self.tick_count
    # why am I wrapping this?
    $gtk.args.tick_count
  end

  # rubocop:disable Metrics/MethodLength
  def self.init(gtk)
    # some side-effects...
    gtk.gtk.set_window_title(':-)')
    gtk.grid.origin_center!
    # and what we're really after, the game model/state
    game = {
      scene: :Flight,
      game_over: false,
      current_level: -1,
      levels: [
        {
          player: { coord: [0, 0], visible: false, size: 1, winner: false },
          show_locus: false,
          targets: [
            { rect: [100, 100, 50, 50], hit: false },
            { rect: [-180, -110, 50, 50], hit: false },
            { rect: [170, 50, 50, 50], hit: false }
          ],
          triangles: [
            {
              locus: [0, 0],
              throttle: 1, # increase theta on tick_count.mod(throttle).zero?
              points: [
                { coord: [0, 0], offset: [0, 0], theta: 0, equation: 1 },
                { coord: [0, 0], offset: [0, 0], theta: 90, equation: 1 },
                { coord: [0, 0], offset: [0, 0], theta: 270, equation: 1 }
              ]
            }
          ]
        },
        {
          player: { coord: [0, 0], visible: false, size: 1, winner: false },
          show_locus: false,
          targets: [
            { rect: [100, 100, 50, 50], hit: false },
            { rect: [-180, -110, 50, 50], hit: false },
            { rect: [170, 50, 50, 50], hit: false }
          ],
          triangles: [
            {
              locus: [0, 0],
              throttle: 1, # increase theta on tick_count.mod(throttle).zero?
              points: [
                { coord: [0, 0], offset: [0, 0], theta: 0, equation: 0 },
                { coord: [0, 0], offset: [0, 0], theta: 90, equation: 0 },
                { coord: [0, 0], offset: [0, 0], theta: 270, equation: 0 }
              ]
            }
          ]
        }
      ],
      show_fps: true,
      mousemaps: {
        Flight: {
          standard_action: %i[button_left],
          alternate_action: %i[button_right]
        },
        Editor: {
          standard_action: %i[button_left],
          alternate_action: %i[button_right]
        }
      },
      keymaps: {
        Flight: {
          left: %i[left a],
          right: %i[right d],
          up: %i[up w],
          down: %i[down s],
          toggle_fps: %i[space],
          exit: %i[escape],
          reset: %i[r],
          load: %i[l],
          save: %i[m]
        },
        Editor: {
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
    }
    puts game
    game
  end
  # rubocop:enable Metrics/MethodLength
end
