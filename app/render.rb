# frozen_string_literal: true

# output methods
module Output
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

  def self.fill_triangle(points)
    primitives = []
    sorted = points.sort_by(&:y)
    a = sorted[0]
    b = sorted[1]
    c = sorted[2]
    dx1 = (b.y - a.y).positive? ? (b.x - a.x) / (b.y - a.y) : 0
    dx2 = (c.y - a.y).positive? ? (c.x - a.x) / (c.y - a.y) : 0
    dx3 = (c.y - b.y).positive? ? (c.x - b.x) / (c.y - b.y) : 0
    s = a.clone
    e = a.clone
    while s.y <= b.y
      primitives << [s.x, s.y, e.x, s.y, 128, 128, 128].line
      s.y += 1
      e.y += 1
      s.x += (dx1 > dx2) ? dx2 : dx1
      e.x += (dx1 > dx2) ? dx1 : dx2
    end
    if dx1 > dx2
      e = b.clone
    else
      s = b.clone
    end
    while s.y <= c.y
      primitives << [s.x, s.y, e.x, s.y, 128, 128, 128].line
      s.y += 1
      e.y += 1
      s.x += (dx1 > dx2) ? dx2 : dx3
      e.x += (dx1 > dx2) ? dx3 : dx2
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
    primitives << fill_triangle([
      triangle[:points][0][:coord],
      triangle[:points][1][:coord],
      triangle[:points][2][:coord]
    ])
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
