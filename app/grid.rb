module Grid
  def render_grid_borders
    @grid_offset = [
      @lx + 290,
      @ly + 5
    ]
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

  class Tile
    attr_sprite
    def initialize x, y, w, h, tile_number
      @x = x
      @y = y
      @w = w
      @h = h
      @source_x = 8 * tile_number.mod(8)
      @source_y = 8 * tile_number.div(8)
      @source_w = 8
      @source_h = 8
      @path = 'media/8BitOverworld/OverworldTileset_01.png' # 8x12 sheet of 8x8 sprites
      @tile_number = tile_number
      $gtk.args.state.seen = [] unless $gtk.args.state.seen
      puts self.to_s unless $gtk.args.state.seen[tile_number];
      $gtk.args.state.seen[tile_number] = true;
    end

    def serialize
      { :x => @x, :y => @y, :w => @w, :h => @h, :source_x => @source_x, :source_y => @source_y, :source_w => @source_w, :source_h => @source_h, :tile_number => @tile_number }
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
      @gtk_outputs.sprites << Tile.new(
        hpos2x(n.mod(8)),
        vpos2y(n.div(8)),
        @grid_segment_size,
        @grid_segment_size,
        n
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

end
