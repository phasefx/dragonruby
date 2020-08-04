module Grid
  def recalc_grid_dimensions
    @grid_offset = [
      @lx + 290,
      @ly + 5
    ]
  end
  def render_grid_outline
    # outer border
    @gtk_outputs.primitives << [
      @grid_offset[0],
      @grid_offset[1],
      @grid_segment_size * @grid_divisions,
      @grid_segment_size * @grid_divisions,
      0, 0, 0, 64
    ].border
    # inner lattices
    if @show_grid_outline
      @grid_divisions.times do |x|
        @grid_divisions.times do |y|
          @gtk_outputs.primitives << [
            @grid_offset[0] + (@grid_segment_size * x),
            @grid_offset[1] + (@grid_segment_size * y),
            @grid_segment_size,
            @grid_segment_size,
            0, 0, 0, 64
          ].border
        end
      end
    end
  end

  class Tile
    attr_sprite
    def initialize x, y, w, h, tile_coords
      @x = x
      @y = y
      @w = w
      @h = h
      @source_x = 8 * tile_coords.x
      @source_y = 8 * tile_coords.y
      @source_w = 8
      @source_h = 8
      @path = 'media/tileset.png' # 32x32 sheet of 8x8 sprites
      @tile_coords = tile_coords
      #$gtk.args.state.seen = {} unless $gtk.args.state.seen
      #puts self.to_s unless $gtk.args.state.seen["#{tile_coords.x}.#{tile_coords.y}"];
      #$gtk.args.state.seen["#{tile_coords.x}.#{tile_coords.y}"] = true;
    end

    def serialize
      { :x => @x, :y => @y, :w => @w, :h => @h, :source_x => @source_x, :source_y => @source_y, :source_w => @source_w, :source_h => @source_h, :tile_coords => @tile_coords }
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end
  end

  def render_tile_sheet
    0.upto(63) do |n|
      grid_x = n.mod(8)
      grid_y = n.div(8)
      @gtk_outputs.sprites << Tile.new(
        hpos2x(grid_x),
        vpos2y(grid_y),
        @grid_segment_size,
        @grid_segment_size,
        [
          bound(grid_x + @palette_coords.x, 0, 32),
          bound(grid_y + @palette_coords.y, 0, 32)
        ]
      )
    end
  end

  ######
  # useful coordinate functions for mapping mouse x,y to cell h,v and vice versa

  def x2hpos x
    ax = x - @grid_offset[0]
    (ax/@grid_segment_size).floor
  end

  def y2vpos y
    ay = y - @grid_offset[1]
    (ay/@grid_segment_size).floor
  end

  def hpos2x hpos
    @grid_offset[0] + (@grid_segment_size * hpos)
  end

  def vpos2y vpos
    @grid_offset[1] + (@grid_segment_size * vpos)
  end

  def wrap v, lb, ub
    lb,ub = ub,lb if lb > ub
    return ub if v < lb
    return lb if v > ub
    v
  end

  def bound v, lb, ub
    lb,ub = ub,lb if lb > ub
    return lb if v < lb
    return ub if v > ub
    v
  end
end
