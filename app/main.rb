# frozen_string_literal: true

require 'app/game_input.rb'
require 'app/game_logic.rb'
require 'app/game_render.rb'
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

def tick(gtk)
  # everything is stored here
  gtk.state.game ||= Game.init gtk
  gtk.state.game = Game.next_level(gtk.state.game, gtk) if gtk.state.game[:desire_next_level]

  # our scene management
  input = Kernel.const_get("#{gtk.state.game[:scene]}Input")
  logic = Kernel.const_get("#{gtk.state.game[:scene]}Logic")
  output = Kernel.const_get("#{gtk.state.game[:scene]}Output")

  # input
  gtk.state.game[:mouse] = {
    position: gtk.inputs.mouse.position,
    any_mouse_down: gtk.inputs.mouse.button_bits.positive?
  }
  meta_intents = input.meta_input(
    gtk.inputs,
    gtk.state.game[:keymaps]
  )
  player_intents = input.player_input(
    gtk.inputs,
    gtk.state.game[:keymaps],
    gtk.state.game[:mousemaps]
  )
  meta_intents << 'reset' if player_intents.include?('alternate_action') && gtk.state.game[:game_over]

  # logic
  gtk.state = logic.meta_intent_handler(
    gtk,
    meta_intents
  )
  gtk.state.game = logic.game_logic(
    gtk.state,
    player_intents
  )

  # output
  gtk.outputs.background_color = GameOutput::BACKGROUND
  outputs = output.render(
    gtk.state.game,
    gtk
  )
  gtk.outputs.primitives << outputs[:primitives]
  outputs[:sounds].each { |s| gtk.outputs.sounds << s }

  if meta_intents.include?('reset')
    gtk.state.game = Game.init gtk
    gtk.gtk.reset
  end
end

# housekeeping
module Game
  # rubocop:disable Security/Eval
  def self.deep_clone(obj)

    # using $gtk is just too convenient to pass up here

    return obj if $gtk.production # for performance

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

  def self.next_level(game,gtk)
    gs = deep_clone game
    gs[:level_index] += 1
    gs[:desire_next_level] = false
    gs[:actors][:targets] = Array.new(5).map do
      {
        label: [
          gtk.grid.left + rand(gtk.grid.w - 12),
          gtk.grid.bottom + rand(gtk.grid.h - 12),
          '*', # '靶',
          GameOutput::ZESTY.sample
        ],
        captured: false
      }
    end
    gs[:actors][:blocks] = Array.new(200).map do
      {
        rect: [
          gtk.grid.left + rand(gtk.grid.w),
          gtk.grid.bottom + rand(gtk.grid.h),
          rand(100) + 100,
          rand(100) + 100
        ],
        direction: [
          (rand(5) + 1).randomize(:sign),
          (rand(5) + 1).randomize(:sign)
        ],
        color: [GameOutput::ZESTY.sample, 128]
      }
    end
    gs
  end

  def self.tick_count
    # why am I wrapping this?
    $gtk.args.tick_count
  end

  def self.init(gtk)
    # some side-effects...
    gtk.gtk.set_window_title(':-)')
    gtk.grid.origin_center!
    # and what we're really after, the game model/state
    game = {
      scene: :Game,
      timer: 20,
      game_over: false,
      level_index: 0,
      desire_next_level: true,
      actors: {
        player: {
          coord: [0, 0],
          visible: false,
          became_visible: false,
          size: 1,
          winner: false,
          total_targets_caught: 0
        }
      },
      show_fps: true,
      mousemaps: {
        Game: {
          standard_action: %i[button_left],
          alternate_action: %i[button_right]
        }
      },
      keymaps: {
        Game: {
          left: %i[left a],
          right: %i[right d],
          up: %i[up w],
          down: %i[down s],
          toggle_fps: %i[space],
          exit: %i[escape],
          reset: %i[r],
          load: %i[l],
          save: %i[m],
          next_level: %i[n]
        }
      }
    }
    puts game
    game
  end
end
