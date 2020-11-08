# frozen_string_literal: true

require 'app/extra_keys.rb'
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
  gtk.state.game = Game.next_level gtk.state.game if gtk.state.game[:desire_next_level]

  # our scene management
  input = Kernel.const_get("#{gtk.state.game[:scene]}Input")
  logic = Kernel.const_get("#{gtk.state.game[:scene]}Logic")
  output = Kernel.const_get("#{gtk.state.game[:scene]}Output")

  # input
  gtk.state.game[:mouse] ||= {}
  gtk.state.game[:mouse][:position] = gtk.inputs.mouse.position
  gtk.state.game[:mouse][:prev_click] = gtk.inputs.mouse.previous_click
  gtk.state.game[:mouse][:last_click] = gtk.inputs.mouse.click if gtk.inputs.mouse.click
  meta_intents = input.meta_input(
    gtk.inputs,
    gtk.state.game[:keymaps]
  )
  player_intents = input.player_input(
    gtk.inputs,
    gtk.state.game[:keymaps],
    gtk.state.game[:mousemaps]
  )

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
  gtk.outputs.background_color = GameOutput::BACKGROUND_COLOR
  outputs = output.render(
    gtk.state.game,
    gtk
  )
  gtk.outputs.primitives << outputs[:primitives]
  if gtk.state.game[:sound]
    outputs[:audio].each do |idx, audio|
      sub_index = 0
      sub_index += 1 until gtk.audio["#{idx}-#{sub_index}"].nil?
      gtk.audio["#{idx}-#{sub_index}"] = audio
      puts "#{idx}-#{sub_index} = #{audio}"
    end
  end

  gtk.gtk.reset if meta_intents.include?('reset')
  return unless gtk.state.game[:desire_pause]

  gtk.state.game[:desire_pause] = false
  gtk.gtk.pause!
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

  def self.next_level(game)
    return game if game[:level_index] == game[:levels].length - 1

    gs = deep_clone game
    gs[:level_index] += 1
    gs[:current_level] = deep_clone gs[:levels][gs[:level_index]]
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
      level_index: -1,
      current_level: nil,
      desire_next_level: true,
      input_buffer: [],
      buttons: [],
      sound: false,
      canonical_audio: [
        {
          filename: 'app/C3.wav',
          gain: 1.0,
          pitch: 3.to_f,
          looping: false,
          paused: false
        },
        {
          filename: 'app/C3.wav',
          gain: 1.0,
          pitch: 4.to_f,
          looping: false,
          paused: false
        },
        {
          filename: 'app/C3.wav',
          gain: 1.0,
          pitch: 5.to_f,
          looping: false,
          paused: false
        },
        {
          filename: 'app/C3.wav',
          gain: 1.0,
          pitch: 6.to_f,
          looping: false,
          paused: false
        },
        {
          filename: 'app/C3.wav',
          gain: 1.0,
          pitch: 7.to_f,
          looping: false,
          paused: false
        },
        {
          filename: 'app/C3.wav',
          gain: 1.0,
          pitch: 8.to_f,
          looping: false,
          paused: false
        },
        {
          filename: 'app/C3.wav',
          gain: 1.0,
          pitch: 9.to_f,
          looping: false,
          paused: false
        },
        {
          filename: 'app/C3.wav',
          gain: 1.0,
          pitch: 10.to_f,
          looping: false,
          paused: false
        },
        {
          filename: 'app/C3.wav',
          gain: 1.0,
          pitch: 11.to_f,
          looping: false,
          paused: false
        },
        {
          filename: 'app/C3.wav',
          gain: 1.0,
          pitch: 12.to_f,
          looping: false,
          paused: false
        },
        {
          filename: 'app/C3.wav',
          gain: 1.0,
          pitch: 13.to_f,
          looping: false,
          paused: false
        }
      ],
      levels: [
        { target_buffer: [1, 2, 3, 4], display_target: [1, 2, 3, '_'] }
      ],
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
          exit: %i[escape],
          reset: %i[r],
          load: %i[l],
          save: %i[m],
          button0: %i[zero num_0],
          button1: %i[one num_1],
          button2: %i[two num_2],
          button3: %i[three num_3],
          button4: %i[four num_4],
          button5: %i[five num_5],
          button6: %i[six num_6],
          button7: %i[seven num_7],
          button8: %i[eight num_8],
          button9: %i[nine num_9],
          button10: %i[backspace],
          button11: %i[num_hyphen],
          button12: %i[num_plus]
        }
      }
    }
    text_dimensions = GameOutput.text_dimensions('123')
    game[:buttons] << {
      x: -1.5 * text_dimensions.x.half + -2 * 1.5 * text_dimensions.x,
      y: -1.5 * text_dimensions.y.half + -1 * 1.5 * text_dimensions.y - 60,
      w: 1.5 * text_dimensions.x,
      h: 1.5 * text_dimensions.y,
      primitive_marker: :border
    }
    [-1, 0, 1].map do |shift_y|
      [-1, 0, 1].map do |shift_x|
        game[:buttons] << {
          x: -1.5 * text_dimensions.x.half + shift_x * 1.5 * text_dimensions.x,
          y: -1.5 * text_dimensions.y.half + shift_y * 1.5 * text_dimensions.y - 60,
          w: 1.5 * text_dimensions.x,
          h: 1.5 * text_dimensions.y,
          primitive_marker: :border
        }
      end
    end
    game[:buttons] << {
      x: -1.5 * text_dimensions.x.half + 2 * 1.5 * text_dimensions.x,
      y: -1.5 * text_dimensions.y.half + 1 * 1.5 * text_dimensions.y - 60,
      w: 1.5 * text_dimensions.x,
      h: 1.5 * text_dimensions.y,
      primitive_marker: :border
    }
    game[:buttons] << {
      x: -1.5 * text_dimensions.x.half + 2 * 1.5 * text_dimensions.x,
      y: -1.5 * text_dimensions.y.half + 0 * 1.5 * text_dimensions.y - 60,
      w: 1.5 * text_dimensions.x,
      h: 1.5 * text_dimensions.y,
      primitive_marker: :border
    }
    game[:buttons] << {
      x: -1.5 * text_dimensions.x.half + 2 * 1.5 * text_dimensions.x,
      y: -1.5 * text_dimensions.y.half + -1 * 1.5 * text_dimensions.y - 60,
      w: 1.5 * text_dimensions.x,
      h: 1.5 * text_dimensions.y,
      primitive_marker: :border
    }
    puts game
    game
  end
end

$gtk.reset
