# frozen_string_literal: true

# https://www.redblobgames.com/grids/hexagons/implementation.html
module HexModule
  def direction(dir)
    raise 'argument should be a value inclusively between 0 and 5' unless dir.to_i.positive? && dir.to_i < 6

    HEX_DIRECTIONS[dir.to_i]
  end

  # toward conversion of hex coordinates to screen coordinates
  class Orientation
    attr_accessor :f0, :f1, :f2, :f3, :b0, :b1, :b2, :b3, :start_angle

    def initialize(f0_, f1_, f2_, f3_, b0_, b1_, b2_, b3_, start_angle)
      @f0 = f0_
      @f1 = f1_
      @f2 = f2_
      @f3 = f3_
      @b0 = b0_
      @b1 = b1_
      @b2 = b2_
      @b3 = b3_
      @start_angle = start_angle
    end

    def serialize
      [@f0, @f1, @f2, @f3, @b0, @b1, @b2, @b3, @start_angle]
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end
  end

  # for converting hex coordinates to screen coordinates
  class Layout
    attr_accessor :orientation, :size, :origin

    def initialize(orientation, size, origin)
      @orientation = orientation
      @size = size
      @origin = origin
    end

    def serialize
      { orientation: @orientation, size: @size, origin: @origin }
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end

    def pixel_to_hex(point)
      pt = [
        (point.x - @origin.x) / @size.x,
        (point.y - @origin.y) / @size.y
      ]
      x = @orientation.b0 * pt.x + @orientation.b1 * pt.y
      y = @orientation.b2 * pt.x + @orientation.b3 * pt.y
      Hex.new(x, y, -x - y)
    end

    def pixel_to_existing_hex(point)
      h = pixel_to_hex(point).round
      $gtk.args.state.hex[h.q][h.r][h.s]
    end

    def hex_to_pixel(hex)
      x = (@orientation.f0 * hex.q + @orientation.f1 * hex.r) * @size.x
      y = (@orientation.f2 * hex.q + @orientation.f3 * hex.r) * @size.y
      [x + @origin.x, y + @origin.y]
    end

    def hex_corner_offset(corner)
      angle = 2.0 * Math::PI * (@orientation.start_angle + corner) / 6
      [@size.x * Math.cos(angle), @size.y * Math.sin(angle)]
    end

    def polygon_corners(hex)
      center = hex_to_pixel(hex)
      6.times.map do |i|
        offset = hex_corner_offset(i)
        [center.x + offset.x, center.y + offset.y]
      end
    end
  end

  # for representing hex cube coordinates
  class Hex
    attr_accessor :q, :r, :s, :base_angle, :hover, :index

    def initialize(q__, r__, s__ = nil)
      @hover = false
      @base_angle = 0
      @q = q__
      @r = r__
      @s = if s__.nil?
             -q__ - r__
           else
             s__
           end
      raise "arguments must sum 0 (was given #{q__}, #{r__}, #{s__})" unless (@q + @r + @s).zero?
    end

    def brief
      [@q, @r, @s]
    end

    def serialize
      { q: @q, r: @r, s: @s, hover: @hover, index: @index }
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end

    def clear_mouse_hover
      if @hover
        @hover = false
        yield
      end
    end

    def set_mouse_hover
      unless @hover
        @hover = true
        yield
      end
    end

    def ==(other)
      @q == other.q && @r == other.r && @s == other.s
    end

    def !=(other)
      !(self == other)
    end

    def +(other)
      Hex.new(@q + other.q, @r + other.r, @s + other.s)
    end

    def -(other)
      Hex.new(@q - other.q, @r - other.r, @s - other.s)
    end

    def *(other)
      Hex.new(@q * other, @r * other, @s * other)
    end

    def length
      ((@q.abs + @r.abs + @s.abs) / 2) # .to_i ?
    end

    def distance(other)
      (self - other).length
    end

    def neighbor(dir)
      add(direction(dir))
    end

    def round
      iq = @q.round
      ir = @r.round
      is = @s.round
      q_diff = (iq - @q).abs
      r_diff = (ir - @r).abs
      s_diff = (is - @s).abs
      if q_diff > r_diff && q_diff > s_diff
        iq = -ir - is
      elsif r_diff > s_diff
        ir = -iq - is
      else
        is = -iq - ir
      end
      Hex.new(iq, ir, is)
    end

    def _lerp(a__, b__, t__)
      a__ * (1 - t__) + b__ * t__
    end

    def lerp(other, t__)
      Hex.new(_lerp(@q, other.q, t__), _lerp(@r, other.r, t__), _lerp(@s, other.s, t__))
    end

    def linedraw(other)
      dist = distance(other).to_i
      step = 1.0 / [dist, 1].max
      dist.times.map { |i| lerp(other, step * i).round }
    end

    def rotate_left
      Hex.new(-@s, -@q, -@r)
    end

    def rotate_right
      Hex.new(-@r, -@s, -@q)
    end
  end

  HEX_DIRECTIONS = [
    Hex.new(1, 0, -1), Hex.new(1, -1, 0), Hex.new(0, -1, 1),
    Hex.new(-1, 0, 1), Hex.new(-1, 1, 0), Hex.new(0, 1, -1)
  ].freeze

  LAYOUT_POINTY = Orientation.new(
    Math.sqrt(3.0), Math.sqrt(3.0) / 2.0, 0.0, 3.0 / 2.0,
    Math.sqrt(3.0) / 3.0, -1.0 / 3.0, 0.0, 2.0 / 3.0,
    0.5
  ).freeze

  LAYOUT_FLAT = Orientation.new(
    3.0 / 2.0, 0.0, Math.sqrt(3.0) / 2.0, Math.sqrt(3.0),
    2.0 / 3.0, 0.0, -1.0 / 3.0, Math.sqrt(3.0) / 3.0,
    0.0
  ).freeze
end

# let's put this stuff to use
class Game
  attr_accessor :scheme, :layout, :hexes, :show_labels, :rotation

  include HexModule

  def initialize(gtk)
    @args = gtk
    @show_labels = false
    @rotation = 0
    gtk.grid.origin_center!
    pointy_layout
    populate_hexes
    _randomize_tiles
    mass_static_render
  end

  def _randomize_tiles
    @random = 255.times.map { rand(7) }
  end

  def randomize_tiles
    _randomize_tiles
    @args.state.game.mass_static_render
  end

  def rotate_right
    @rotation -= 30
    mass_static_render
  end

  def rotate_left
    @rotation += 30
    mass_static_render
  end

  def hex_sprite(h, i)
    coord = @layout.hex_to_pixel(h)
    path = "media/grass_1#{@random[i]}.png"
    case @scheme
    when :pointy
      h.base_angle = 0
      {
        x: coord.x - 60, y: coord.y - 70,
        w: 120, h: 140, angle: h.base_angle + @rotation,
        path: path
      }
    when :flat
      h.base_angle = 30
      {
        x: coord.x - 60, y: coord.y - 70,
        w: 120, h: 140, angle: h.base_angle + @rotation,
        r: h.hover ? 255 : 255,
        g: 255,
        b: 255,
        path: path
      }
    end
  end

  def hex_label(h)
    coord = @layout.hex_to_pixel(h)
    {
      x: coord.x - 25, y: coord.y + 10, text: h.brief.join(','),
      r: h.hover ? 255 : 0,
      g: 0,
      b: 0
    }
  end

  def hex_lines(h)
    polygon_corners_to_lines(@layout.polygon_corners(h))
  end

  def mass_static_render_sprites
    @args.outputs.static_primitives << @hexes.each_with_index.map do |h, i|
      hex_sprite(h, i).sprite
    end
  end

  def mass_static_render_labels
    return unless @show_labels

    @args.outputs.static_labels << @hexes.map do |h|
      hex_label(h)
    end
  end

  def mass_static_render_lines
    @args.outputs.static_primitives << @hexes.each_with_index.map do |h, i|
      hex_lines(h).lines
    end
  end

  def mass_static_render
    @args.outputs.static_primitives.clear
    @args.outputs.static_labels.clear
    mass_static_render_sprites
    mass_static_render_labels
    mass_static_render_lines
  end

  def populate_hexes
    # flat array, but also vivicating a map in @args.state
    @hexes = (-4..4).map do |q|
      (-4..4).map do |r|
        h = Hex.new(q, r)
        @args.state.hex[q][r][-q - r] = h
        h
      end
    end.flatten
    @hexes.each_with_index do |h, i|
      h.index = i
    end
  end

  def toggle_labels
    @show_labels = !@show_labels
    @args.outputs.static_labels.clear
    mass_static_render_labels
  end

  def toggle_layout
    case @scheme
    when :flat
      pointy_layout
    when :pointy
      flat_layout
    end
    mass_static_render
  end

  def flat_layout
    @scheme = :flat
    @layout = Layout.new(LAYOUT_FLAT, [70, 70], [0, 0])
  end

  def pointy_layout
    @scheme = :pointy
    @layout = Layout.new(LAYOUT_POINTY, [70, 70], [0, 0])
  end

  def serialize
    { scheme: @scheme, layout: @layout, hexes: @hexes }
  end

  def inspect
    serialize.to_s
  end

  def to_s
    serialize.to_s
  end

  def polygon_corners_to_lines(corners)
    corners.each_with_index.map do |corner, idx|
      [corner.x, corner.y, corners[idx - 1].x, corners[idx - 1].y]
    end
  end
end

def tick(args)
  # init
  args.state.game ||= Game.new(args)

  # clearing for tick
  intents = []
  args.state.game.hexes.each do |h|
    h.clear_mouse_hover do
      args.outputs.static_labels[h.index] = args.state.game.hex_label(h) if args.state.game.show_labels
    end
  end

  # input
  down_keys = args.inputs.keyboard.key_down.truthy_keys
  down_keys.each do |truth|
    intents << :toggle_layout if truth == :space
    intents << :toggle_labels if truth == :c
    intents << :randomize_tiles if truth == :r
    intents << :rotate_right if truth == :right
    intents << :rotate_left if truth == :left
  end
  mouse_hex = args.state.game.layout.pixel_to_existing_hex(
    [args.inputs.mouse.position.x, args.inputs.mouse.position.y]
  )

  # logic
  mouse_hex&.set_mouse_hover do
    args.outputs.static_labels[mouse_hex.index] = args.state.game.hex_label(mouse_hex) if args.state.game.show_labels
  end
  args.state.game.toggle_layout if intents.include?(:toggle_layout)
  args.state.game.toggle_labels if intents.include?(:toggle_labels)
  args.state.game.randomize_tiles if intents.include?(:randomize_tiles)
  args.state.game.rotate_left if intents.include?(:rotate_left)
  args.state.game.rotate_right if intents.include?(:rotate_right)

  # render
  args.outputs.labels << [args.grid.left, args.grid.top, "FPS #{args.gtk.current_framerate.to_i}"].label
  args.outputs.labels << [args.grid.left, args.grid.top - 21, 'R for Randomize'].label
  args.outputs.labels << [args.grid.left, args.grid.top - 42, 'C for Coordinates'].label
  args.outputs.labels << [args.grid.left, args.grid.top - 63, 'Space for Orientation'].label
end

$gtk.reset
