# frozen_string_literal: true

# https://www.redblobgames.com/grids/hexagons/implementation.html
module HexModule
  def direction(dir)
    raise 'argument should be a value inclusively between 0 and 5' unless dir.to_i.positive? && dir.to_i < 6

    HEX_DIRECTIONS[dir.to_i]
  end

  # toward conversion of hex coordinates to screen coordinates
  class Orientation
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
  end

  # for converting hex coordinates to screen cordinates
  class Layout
    def initialize(orientation, size, origin)
      @orientation = orientation
      @size = size
      @orgin = origin
    end

    # rubocop: disable Metrics/AbcSize
    def hex_to_pixel(hex)
      x = (@orientation.f0 * hex.q + @orientation.f1 * hex.r) * @size.x
      y = (@orientation.f2 * hex.q + @orientation.f3 * hex.r) * @size.y
      [x + @origin.x, y + @origin.y]
    end
    # rubocop: enable Metrics/AbcSize
  end

  # for representing hex cube coordinates
  class Hex
    attr_accessor :q, :r, :s

    def initialize(q__, r__, s__)
      @q = q__
      @r = r__
      @s = s__
      raise 'arguments must sum 0' unless (@q + @r + @s).zero?
    end

    def serialize
      { q: @q, r: @r, s: @r }
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
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
        iq = -@r - @s
      elsif r_diff > s_diff
        ir = -@q - @s
      else
        is = -@q - @r
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
  attr_accessor :layout, :hex

  include HexModule

  def initialize(gtk)
    @args = gtk
    gtk.grid.origin_center!
    @layout = Layout.new(LAYOUT_FLAT, [100, 100], [0, 0])
    @hex = Hex.new(0, 0, 0)
  end

  def serialize
    { hex: @hex }
  end

  def inspect
    serialize.to_s
  end

  def to_s
    serialize.to_s
  end
end

def tick(args)
  args.state.game ||= Game.new(args)
  args.outputs.labels << [100, 100, args.state.tick_count]
end

# rubocop: disable Style/GlobalVars
$gtk.reset
# rubocop: enable Style/GlobalVars
