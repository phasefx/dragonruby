# frozen_string_literal: true

# This is our entry-point into DragonRuby Game Toolkit
def tick(gtk)
  gtk.state.game ||= init gtk
  player_intents = input gtk
  gtk.state.game = logic gtk.state.game, player_intents
  gtk.outputs.primitives << render(gtk.state.game, gtk)
end

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

def input(gtk)
  intents = []
  exit if gtk.inputs.keyboard.escape # can't escape side-effects here, harr
  intents << 'toggle_fps' if gtk.inputs.keyboard.spacebar
  intents
end

def logic(state, intents)
  state.show_fps = !state.show_fps if intents.include?('toggle_fps')
  state
end

def render(state, gtk)
  primitives = []
  primitives << render_fps(state, gtk)
  primitives
end

def render_fps(state, gtk)
  primitives = []
  text_height = gtk.gtk.calcstringbox('H')[1]
  if state.dig(:show_fps)
    primitives << [
      gtk.grid.left,
      gtk.grid.top - text_height * 0,
      "FPS #{gtk.gtk.current_framerate.floor}  Tick #{gtk.tick_count}"
    ].labels
  end
  primitives
end
