# frozen_string_literal: true

MINIGAME = false

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
  if gtk.state.tick_count.zero? || (gtk.state.game[:desire_next_level] && gtk.state.game[:game_over])
    gtk.state.game = Game.init gtk
  end
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
  if player_intents.include?('alternate_action') && gtk.state.game[:game_over]
    meta_intents << 'reset' unless MINIGAME
    exit if MINIGAME
  end

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

  Game.reset(gtk) if meta_intents.include?('reset')
end

# housekeeping
module Game
  def self.reset(gtk)
    gtk.state.game = init gtk
    gtk.gtk.reset
  end

  def self.deep_clone(obj)
    # using $gtk is just too convenient to pass up here

    return obj if $gtk.production # for performance

    # well, if the above works and the following doesn't:
    #
    #  eval $gtk.serialize_state obj
    #
    # then let's just return the object then. I'm not sure
    # why I was trying to clone here; maybe an experiment
    # in using pure functional programming

    return obj
  end

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

  def self.different_from_previous_level?(game)
    game[:previous_cloud_or_tunnel] != game[:cloud_or_tunnel] # && game[:previous_palette] != game[:palette]
  end

  def self.next_level(game, gtk)
    gs = deep_clone game
    gs[:level_index] += 1
    gs[:desire_next_level] = false
    gs[:desire_next_level_at] = nil
    gtk.state.volatile = {}
    loop do
      gs[:cloud_or_tunnel] = rand(2) == 1 ? :cloud : :tunnel
      gs[:palette] = rand(GameOutput::PALETTES.length)
      break if different_from_previous_level?(gs)
    end
    gs[:previous_cloud_or_tunnel] = gs[:cloud_or_tunnel]
    gs[:previous_palette] = gs[:palette]
    tunnel_set_size = [200, 200, 101, 100]
    tunnel_set = rand(4)
    gs[:bg_size] = tunnel_set_size[tunnel_set]
    idx = 0
    gtk.state.volatile[:backgrounds] = Array.new(gs[:cloud_or_tunnel] == :tunnel ? gs[:bg_size] : 0).map do
      idx += 1
      path = "media/tunnel#{tunnel_set}/ezgif-frame-#{format('%03<frame>d', frame: idx)}.jpg"
      GameOutput::Background.new(path)
    end
    gtk.state.volatile[:targets] = Array.new(5).map do
      GameOutput::Label.new(
        gtk.grid.left + rand(gtk.grid.w - 12),
        gtk.grid.bottom + 12 + GameLogic.bound(rand(gtk.grid.h - 12), 0, gtk.grid.h),
        '*',
        GameOutput::PALETTES[gs[:palette]].sample,
        128
      )
    end
    gs[:actors][:targets] = gtk.state.volatile[:targets].map do |t|
      {
        object_id: t.object_id,
        captured: false
      }
    end
    gtk.state.volatile[:blocks] = Array.new(gs[:cloud_or_tunnel] == :cloud ? 200 : 0).map do
      GameOutput::Solid.new(
        gtk.grid.left + rand(gtk.grid.w),
        gtk.grid.bottom + rand(gtk.grid.h),
        rand(100) + 100,
        rand(100) + 100,
        GameOutput::PALETTES[gs[:palette]].sample,
        128
      )
    end
    gs[:actors][:blocks] = gtk.state.volatile[:blocks].map do |b|
      {
        object_id: b.object_id,
        direction: [
          (rand(5) + 1).randomize(:sign),
          (rand(5) + 1).randomize(:sign)
        ]
      }
    end
    gtk.outputs.static_primitives.clear
    gtk.outputs.static_primitives << gtk.state.volatile[:targets] # targets first to make them more obscure
    gtk.outputs.static_primitives << gtk.state.volatile[:blocks]
    gs
  end

  def self.tick_count
    # why am I wrapping this?
    $gtk.args.tick_count
  end

  def self.init(gtk)
    # some side-effects...
    #gtk.gtk.set_window_title(':-)')
    gtk.grid.origin_center!
    # and what we're really after, the game model/state
    game = {
      scene: :Game,
      timer: 20,
      game_over: false,
      bg_index: 0,
      previous_palette: nil,
      palette: 0,
      previous_cloud_or_tunnel: :tunnel, # let's start with clouds
      cloud_or_tunnel: nil,
      level_index: 0,
      desire_next_level: true,
      desire_next_level_at: -100,
      actors: {
        player: {
          coord: [0, 0],
          visible: false,
          became_visible: false,
          size: 20,
          click_count: 0,
          winner: false,
          score: 0,
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
