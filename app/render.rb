# frozen_string_literal: true

# output methods
module Output
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def self.render(game, gtk)
    primitives = []
    primitives << render_line(
      game[:actors][:triangles][0][:points][0],
      game[:actors][:triangles][0][:points][1], 255, 0, 0
    )
    primitives << render_line(
      game[:actors][:triangles][0][:points][1],
      game[:actors][:triangles][0][:points][2], 0, 255, 0
    )
    primitives << render_line(
      game[:actors][:triangles][0][:points][0],
      game[:actors][:triangles][0][:points][2], 0, 0, 255
    )
    primitives << render_fps(game, gtk)
    primitives
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  def self.render_line(point1, point2, red, green, blue)
    primitives = []
    primitives << {
      x: point1[:coord].x, y: point1[:coord].y,
      x2: point2[:coord].x, y2: point2[:coord].y,
      r: red, g: green, b: blue, a: 255
    }.line

    primitives
  end

  def self.render_fps(state, gtk)
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
end
