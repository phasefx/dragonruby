# frozen_string_literal: true

# output methods
module FlightOutput
  # rubocop:disable Metrics/AbcSize
  # _rubocop:disable Metrics/MethodLength
  def self.render(game, gtk)
    primitives = []
    primitives << game[:actors][:triangles].map { |t| render_triangle(t, game[:actors][:show_locus]) }
    primitives << game[:actors][:targets].map { |t| render_target(t) }
    primitives << render_player(game[:actors][:player])
    primitives << render_fps(game, gtk)
    primitives
  end
  # _rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  def self.render_target(target)
    primitives = []
    primitives << if target[:hit]
                    target[:rect].solid
                  else
                    target[:rect].border
                  end
    primitives
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def self.render_triangle(triangle, show_locus)
    primitives = []
    if show_locus
      primitives << render_line(
        Game.v_add(triangle[:locus], triangle[:points][0][:coord], triangle[:points][0][:offset]),
        triangle[:locus], 128, 128, 128
      )
      primitives << render_line(
        Game.v_add(triangle[:locus], triangle[:points][1][:coord], triangle[:points][0][:offset]),
        triangle[:locus], 128, 128, 128
      )
      primitives << render_line(
        Game.v_add(triangle[:locus], triangle[:points][2][:coord], triangle[:points][0][:offset]),
        triangle[:locus], 128, 128, 128
      )
    end
    primitives << render_line(
      Game.v_add(triangle[:locus], triangle[:points][0][:coord], triangle[:points][0][:offset]),
      Game.v_add(triangle[:locus], triangle[:points][1][:coord], triangle[:points][1][:offset]), 255, 0, 0
    )
    primitives << render_line(
      Game.v_add(triangle[:locus], triangle[:points][1][:coord], triangle[:points][1][:offset]),
      Game.v_add(triangle[:locus], triangle[:points][2][:coord], triangle[:points][2][:offset]), 0, 255, 0
    )
    primitives << render_line(
      Game.v_add(triangle[:locus], triangle[:points][0][:coord], triangle[:points][0][:offset]),
      Game.v_add(triangle[:locus], triangle[:points][2][:coord], triangle[:points][2][:offset]), 0, 0, 255
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

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def self.render_fps(state, gtk)
    primitives = []
    text_height = gtk.gtk.calcstringbox('H')[1]
    primitives << if state[:show_fps]
                    [
                      gtk.grid.left,
                      gtk.grid.top - text_height * 0,
                      "FPS #{gtk.gtk.current_framerate.floor}  Tick #{gtk.tick_count} Level #{state[:current_level]}"
                    ].labels
                  else
                    [
                      gtk.grid.left,
                      gtk.grid.top - text_height * 0,
                      "Level #{state[:current_level]}"
                    ].labels
                  end
    primitives << [
      gtk.grid.left,
      gtk.grid.top - text_height * 1,
      'R for Reset / M for Save / L for Load'
    ].labels
    primitives << [
      gtk.grid.left,
      gtk.grid.top - text_height * 2,
      'Hold Left Mouse Button for square to trap vertices'
    ].labels
    if state[:actors][:show_locus]
      primitives << [
        gtk.grid.left,
        gtk.grid.top - text_height * 3,
        'Showing Loci'
      ].labels
    elsif state[:actors][:player][:winner]
      primitives << [
        gtk.grid.left,
        gtk.grid.top - text_height * 3,
        'WINNER!'
      ].labels
    end
    primitives
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize
end
