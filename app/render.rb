# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize
def render(game, gtk)
  primitives = []
  primitives << render_line(game[:anchors][0], game[:anchors][1], 255, 0, 0)
  primitives << render_line(game[:anchors][1], game[:anchors][2], 0, 255, 0)
  primitives << render_line(game[:anchors][0], game[:anchors][2], 0, 0, 255)
  primitives << render_fps(game, gtk)
  primitives
end
# rubocop:enable Metrics/AbcSize

def render_line(point1, point2, red, green, blue)
  primitives = []
  primitives << {
    x: point1[:coord].x, y: point1[:coord].y,
    x2: point2[:coord].x, y2: point2[:coord].y,
    r: red, g: green, b: blue, a: 255
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
