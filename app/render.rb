# frozen_string_literal: true

def render(game, gtk)
  primitives = []
  primitives << render_player(game[:player], gtk)
  primitives << render_fps(game, gtk)
  primitives
end

def render_player(player, gtk)
  primitives = []
  # return primitives unless state[:player][:coord].intersect_rec? gtk.grid.rect
  primitives << {
    x: gtk.grid.center_x, y: gtk.grid.center_y,
    x2: player[:coord].x, y2: player[:coord].y,
    r: 255, g: 0, b: 0, a: 255
  }.line

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
