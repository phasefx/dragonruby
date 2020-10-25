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

    # rubocop: disable Style/ParameterLists
    def initialize(f0_, f1_, f2_, f3_, b0_, b1_, b2_, b3_, start_angle)
      # rubocop: enable Style/ParameterLists
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

    # rubocop: disable Metrics/AbcSize
    def pixel_to_hex(point)
      pt = [
        (point.x - @origin.x) / @size.x,
        (point.y - @origin.y) / @size.y
      ]
      x = @orientation.b0 * pt.x + @orientation.b1 * pt.y
      y = @orientation.b2 * pt.x + @orientation.b3 * pt.y
      Hex.new(x, y, -x - y)
    end
    # rubocop: enable Metrics/AbcSize

    def pixel_to_existing_hex(point)
      h = pixel_to_hex(point).round
      # rubocop: disable Style/GlobalVars
      $gtk.args.state.hex[h.q][h.r][h.s]
      # rubocop: enable Style/GlobalVars
    end

    # rubocop: disable Metrics/AbcSize
    def hex_to_pixel(hex)
      x = (@orientation.f0 * hex.q + @orientation.f1 * hex.r) * @size.x
      y = (@orientation.f2 * hex.q + @orientation.f3 * hex.r) * @size.y
      [x + @origin.x, y + @origin.y]
    end
    # rubocop: enable Metrics/AbcSize

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
    attr_accessor :q, :r, :s, :hover

    def initialize(q__, r__, s__ = nil)
      @hover = false
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
      { q: @q, r: @r, s: @s, hover: @hover }
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end

    def clear_mouse_hover
      @hover = false
    end

    def ==(other)
      @q == other.q && @r == other.r && @s == other.s
    end

    def !=(other)
      # rubocop: disable Style/InverseMethods
      !(self == other)
      # rubocop: enable Style/InverseMethods
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

    # rubocop: disable Metrics/MethodLength
    # rubocop: disable Metrics/AbcSize
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
    # rubocop: enable Metrics/AbcSize
    # rubocop: enable Metrics/MethodLength

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
  attr_accessor :layout, :hexes

  include HexModule

  def initialize(gtk)
    @args = gtk
    gtk.grid.origin_center!
    flat_layout
    populate_hexes
  end

  def populate_hexes
    # flat array, but also populating a map in @args.state
    @hexes = (-4..4).map do |q|
      (-4..4).map do |r|
        h = Hex.new(q, r)
        @args.state.hex[q][r][-q - r] = h
        h
      end
    end.flatten
  end

  def toggle_layout
    case @scheme
    when :flat
      pointy_layout
    when :pointy
      flat_layout
    end
  end

  def flat_layout
    @scheme = :flat
    @layout = Layout.new(LAYOUT_FLAT, [50, 50], [0, 0])
  end

  def pointy_layout
    @scheme = :pointy
    @layout = Layout.new(LAYOUT_POINTY, [50, 50], [0, 0])
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

# rubocop: disable Metrics/AbcSize
# rubocop: disable Metrics/MethodLength
# rubocop: disable Metrics/CyclomaticComplexity
# rubocop: disable Metrics/PerceivedComplexity
def tick(args)
  # init
  args.state.game ||= Game.new(args)

  # clearing for tick
  intents = []
  args.state.game.hexes.each(&:clear_mouse_hover)

  # input
  down_keys = args.inputs.keyboard.key_down.truthy_keys
  down_keys.each do |truth|
    intents << :toggle_layout if truth == :space
  end
  mouse_hex = args.state.game.layout.pixel_to_existing_hex(
    [args.inputs.mouse.position.x, args.inputs.mouse.position.y]
  )

  # logic
  mouse_hex.hover = true unless mouse_hex.nil?
  args.state.game.toggle_layout if intents.include?(:toggle_layout)

  # render
  args.outputs.labels << args.state.game.hexes.map do |h|
    coord = args.state.game.layout.hex_to_pixel(h)
    {
      x: coord.x - 25, y: coord.y + 10, text: h.brief.join(','),
      r: h.hover ? 255 : 0,
      g: 0,
      b: 0
    }
  end
  args.outputs.lines << args.state.game.hexes.map do |h|
    args.state.game.polygon_corners_to_lines(args.state.game.layout.polygon_corners(h))
  end
end
# rubocop: enable Metrics/PerceivedComplexity
# rubocop: enable Metrics/CyclomaticComplexity
# rubocop: enable Metrics/MethodLength
# rubocop: enable Metrics/AbcSize

# rubocop: disable Style/GlobalVars
$gtk.reset
# rubocop: enable Style/GlobalVars
