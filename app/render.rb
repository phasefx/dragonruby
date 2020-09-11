# frozen_string_literal: true

def render(game, gtk)
  primitives = []
  primitives << render_player_and_anchor(game[:player], game[:anchors][0], gtk)
  primitives << render_fps(game, gtk)
  primitives
end

def render_player_and_anchor(player, anchor, _gtk)
  primitives = []
  # return primitives unless state[:player][:coord].intersect_rec? gtk.grid.rect
  primitives << {
    x: anchor[:coord].x, y: anchor[:coord].y,
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
