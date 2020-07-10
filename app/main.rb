class Game

  # for debugging: $gtk.args.state.game.cells, etc
  attr_accessor :cells

  TEXT_HEIGHT = 20

  def initialize args

    $gtk.set_window_title 'Dewey Decimate System'

    @gtk_args = args
    @gtk_inputs = args.inputs
    @gtk_outputs = args.outputs
    @gtk_state = args.state
    @gtk_grid = args.grid
    @gtk_kb = @gtk_inputs.keyboard
    @gtk_mouse = @gtk_inputs.mouse

    @lx = @gtk_grid.left
    @ux = @gtk_grid.right
    @ly = @gtk_grid.bottom
    @uy = @gtk_grid.top
    @w = @ux - @lx
    @h = @uy - @ly

    @grid_divisions = 2
    @delay = 1

    @cells = Array.new(@grid_divisions){Array.new(@grid_divisions,false)}
    @next_cells = Array.new(@grid_divisions){Array.new(@grid_divisions,true)}
    @audio = false

    render_grid
    init_cells
    static_render
  end

  def serialize
    {cells:@cells}
  end

  def inspect
    serialize.to_s
  end

  def to_s
    serialize.to_s
  end

  def render_grid
    @grid_segment_size = (@h-10)/(@grid_divisions)
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

  def static_render
    ##                                                     '1234567890123456789012345678' ]
    #@gtk_outputs.static_labels << [@lx,@uy-TEXT_HEIGHT*21,'Press Enter for demo']
  end

  class Sprite
    attr_sprite
    attr_accessor :x, :y, :w, :h, :type

    def initialize x, y, w, h, type=nil
      @x = x
      @y = y
      @w = w
      @h = h
      @r = 255
      @g = 255
      @b = 255
      @a = 255
      @type = type
      @path = "media/icons/BookOrigin #{@type}.png"
    end

    def rebuild x, y, w, h
      @x = x
      @y = y
      @w = w
      @h = h
      @path = "media/icons/BookOrigin #{@type}.png"
      self
    end

    def serialize
      {x:@x,y:@y,w:@w,h:@h,type:@type,path:@path}
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end
  end

  class Book
    attr_accessor :x, :y, :w, :h, :type, :state, :sprite

    def initialize x, y, w, h, type=nil
      @x = x
      @y = y
      @w = w
      @h = h
      @type = type.nil? ? rand(7) + 1 : type
      @sprite = Sprite.new(@x,@y,@w,@h,@type)
    end

    def rebuild x, y, w, h
      @x = x
      @y = y
      @w = w
      @h = h
      @sprite.x = @x
      @sprite.y = @y
      @sprite.w = @W
      @sprite.h = @h
      @sprite.rebuild @x, @y, @w, @h
      self
    end

    def serialize
      {state:@state,x:@x,y:@y,w:@w,h:@h,type:@type,sprite:@sprite}
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end
  end

  def init_cells
    @cells.each_with_index do |row, hpos|
      row.each_with_index do |cell, vpos|
        @cells[hpos][vpos] = Book.new(
          @grid_offset[0] + (@grid_segment_size * hpos),
          @grid_offset[1] + (@grid_segment_size * vpos),
          @grid_segment_size,
          @grid_segment_size
        )
      end
    end
  end

  def render_cells
    @cells.each_with_index do |row, hpos|
      row.each_with_index do |cell, vpos|
        #if [1..34].include? cell.type then
          @gtk_outputs.sprites << @cells[hpos][vpos].sprite
        #end
      end
    end
  end

  def handle_cell_toggle cell_type, keyboard_entry
    x = @gtk_mouse.x - @grid_offset[0]
    y = @gtk_mouse.y - @grid_offset[1]
    hpos = (x/(@grid_segment_size)).floor
    vpos = (y/(@grid_segment_size)).floor
    if hpos > -1 && hpos < @grid_divisions && vpos > -1 && vpos < @grid_divisions && !(hpos == @prev_hpos && vpos == @prev_vpos && !keyboard_entry) then
      @iteration = 0
      @prev_hpos = hpos
      @prev_vpos = vpos
      #if @cells[hpos][vpos] then
      #  @cells[hpos][vpos] = cell_type
      #end
    end
  end

  def handle_mouse
    if @gtk_mouse.down || @mouse_down then
      @mouse_down = true
      handle_cell_toggle @gtk_mouse.button_left ? :normal : (@gtk_mouse.button_middle ? :pit : :immortal), false
    end
    if @gtk_mouse.up then
      @mouse_down = false
      @prev_hpos = nil
      @prev_vpos = nil
    end
  end

  def handle_keyboard
    @gtk_kb.key_down.truthy_keys.each do |truth|
      if truth == :close_square_brace then
        @grid_divisions += 1
        @grid_segment_size = (@h-10)/(@grid_divisions)
        @next_cells = Array.new(@grid_divisions){Array.new(@grid_divisions,true)}
        temp = @cells
        @cells = Array.new(@grid_divisions){Array.new(@grid_divisions,false)}
        @cells.each_with_index do |row, hpos|
          row.each_with_index do |cell, vpos|
            if temp[hpos].nil? || temp[hpos][vpos].nil? then
              @cells[hpos][vpos] = Book.new(
                @grid_offset[0] + (@grid_segment_size * hpos),
                @grid_offset[1] + (@grid_segment_size * vpos),
                @grid_segment_size,
                @grid_segment_size
              )
            else
              @cells[hpos][vpos] = temp[hpos][vpos]
              @cells[hpos][vpos].rebuild(
                @grid_offset[0] + (@grid_segment_size * hpos),
                @grid_offset[1] + (@grid_segment_size * vpos),
                @grid_segment_size,
                @grid_segment_size
              )
            end
          end
        end
        @iteration = 0
      end
      if truth == :open_square_brace then
        @grid_divisions -= 1
        @grid_divisions = 1 if @grid_divisions < 1
        @grid_segment_size = (@h-10)/(@grid_divisions)
        @next_cells = Array.new(@grid_divisions){Array.new(@grid_divisions,true)}
        temp = @cells
        @cells = Array.new(@grid_divisions){Array.new(@grid_divisions,false)}
        @cells.each_with_index do |row, hpos|
          row.each_with_index do |cell, vpos|
            if temp[hpos].nil? || temp[hpos][vpos].nil? then
              @cells[hpos][vpos] = Book.new(
                @grid_offset[0] + (@grid_segment_size * hpos),
                @grid_offset[1] + (@grid_segment_size * vpos),
                @grid_segment_size,
                @grid_segment_size
              )
            else
              @cells[hpos][vpos] = temp[hpos][vpos]
              @cells[hpos][vpos].rebuild(
                @grid_offset[0] + (@grid_segment_size * hpos),
                @grid_offset[1] + (@grid_segment_size * vpos),
                @grid_segment_size,
                @grid_segment_size
              )
            end
          end
        end
        @iteration = 0
      end
      if truth == :comma then
        @delay -= 1
        @delay = 1 if @delay < 1
      end
      if truth == :period then
        @delay += 1
      end
      if truth == :three && !@saved.nil? then # restore
        @iteration = 0
        @cells.each_with_index do |row, hpos|
          row.each_with_index do |cell, vpos|
            if @saved[hpos].nil? || @saved[hpos][vpos].nil? then
              @cells[hpos][vpos] = Book.new(
                @grid_offset[0] + (@grid_segment_size * hpos),
                @grid_offset[1] + (@grid_segment_size * vpos),
                @grid_segment_size,
                @grid_segment_size
              )
            else
              @cells[hpos][vpos] = @saved[hpos][vpos].rebuild(
                @grid_offset[0] + (@grid_segment_size * hpos),
                @grid_offset[1] + (@grid_segment_size * vpos),
                @grid_segment_size,
                @grid_segment_size
              )
            end
          end
        end
      end
      if truth == :four then # save
        @saved = Array.new(@grid_divisions){Array.new(@grid_divisions,true)}
        @cells.each_with_index do |row, hpos|
          row.each_with_index do |cell, vpos|
            @saved[hpos][vpos] = @cells[hpos][vpos]
          end
        end
      end
      if truth == :a then
        @audio = !@audio
      end
      if truth == :left then
        @cells = @cells.rotate(1)
      end
      if truth == :right then
        @cells = @cells.rotate(-1)
      end
      if truth == :down then
        @cells.each_with_index do |row, hpos|
          @cells[hpos] = @cells[hpos].rotate(1)
        end
      end
      if truth == :up then
        @cells.each_with_index do |row, hpos|
          @cells[hpos] = @cells[hpos].rotate(-1)
        end
      end
    end
  end

  def wrap pos
    return @grid_divisions - 1 if pos < 0
    return 0 if pos > @grid_divisions - 1
    return pos
  end

  def render_right_pane
    #@gtk_outputs.labels << [ @grid_offset[0]+(@grid_segment_size*@grid_divisions), @uy,               'Cell rules:' ]
    ##                                                                                                 '1234567890123456789012345678' ]
  end

  def tick
    handle_mouse
    handle_keyboard
    render_grid
    render_cells
    render_right_pane
    if @audio then
    end
  end
end

def tick args
  args.state.game ||= Game.new args
  args.state.game.tick
end
