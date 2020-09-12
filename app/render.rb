# frozen_string_literal: true

# output methods
module Output
  # _rubocop:disable Metrics/AbcSize
  # _rubocop:disable Metrics/MethodLength
  def self.render(game, gtk)
    primitives = []
    primitives << game[:actors][:triangles].map { |t| render_triangle(t) }
    primitives << render_player(game[:actors][:player])
    primitives << render_fps(game, gtk)
    primitives
  end
  # _rubocop:enable Metrics/MethodLength
  # _rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def self.render_triangle(triangle)
    primitives = []
    primitives << render_line(
      triangle[:points][0][:coord],
      triangle[:points][1][:coord], 255, 0, 0
    )
    primitives << render_line(
      triangle[:points][1][:coord],
      triangle[:points][2][:coord], 0, 255, 0
    )
    primitives << render_line(
      triangle[:points][0][:coord],
      triangle[:points][2][:coord], 0, 0, 255
    )
    primitives
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  def self.render_line(point1, point2, red, green, blue)
    primitives = []
    primitives << {
      x: point1.x, y: point1.y,
      x2: point2.x, y2: point2.y,
      r: red, g: green, b: blue, a: 255
    }.line

    primitives
  end

  # _rubocop:disable Metrics/AbcSize
  # _rubocop:disable Metrics/MethodLength
  def self.render_player(player)
    primitives = []
    return primitives unless player[:visible]

    primitives << player[:rect].border
    primitives
  end
  # _rubocop:enable Metrics/MethodLength
  # _rubocop:enable Metrics/AbcSize

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
