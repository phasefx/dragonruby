# frozen_string_literal: true

def render(state, gtk)
  primitives = []
  primitives << render_fps(state, gtk)
  primitives
end

def render_fps(state, gtk)
  primitives = []
  text_height = gtk.gtk.calcstringbox('H')[1]
  if state[:show_fps]
    primitives << [
      gtk.grid.left,
      gtk.grid.top - text_height * 0,
      "FPS #{gtk.gtk.current_framerate.floor}  Tick #{gtk.tick_count}"
    ].labels
  end
  primitives
end
