class Game

  # for debugging: $gtk.args.state.game.cells, etc
  attr_accessor :cells, :state

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

    @grid_divisions = 8
    @delay = 1

    @state = :seeking_first_token
    #        :seeking_second_token
    #        :testing_swap
    #        :clearing_matches
    #        :populating_empty_cells

    @cells = Array.new(@grid_divisions){Array.new(@grid_divisions,false)}
    @next_cells = Array.new(@grid_divisions){Array.new(@grid_divisions,true)}
    @audio = false

    render_grid # do this now so that we have @grid_segment_size ready for init_cells
    init_cells
    static_render
  end

  def serialize
    {state:@state}
  end

  def inspect
    serialize.to_s
  end

  def to_s
    serialize.to_s
  end

  def set_state s
    puts "stage change: #{@state} to #{s}"
    @state = s
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
    attr_accessor :x, :y, :w, :h, :angle, :type

    def initialize x, y, w, h, type=nil
      @x = x
      @y = y
      @w = w
      @h = h
      @angle = 0
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
          hpos2x(hpos),
          vpos2y(vpos),
          @grid_segment_size,
          @grid_segment_size
        )
      end
    end
  end

  def render_cells
    @cells.each_with_index do |row, hpos|
      row.each_with_index do |cell, vpos|
        @gtk_outputs.sprites << @cells[hpos][vpos].sprite
        if @cells[hpos][vpos].state == :first_token then
          @gtk_outputs.solids << [
            hpos2x(hpos),
            vpos2y(vpos),
            @grid_segment_size,
            @grid_segment_size,
            0, 0, 255, 64
          ]
        elsif @cells[hpos][vpos].state == :second_token then
          @gtk_outputs.solids << [
            hpos2x(hpos),
            vpos2y(vpos),
            @grid_segment_size,
            @grid_segment_size,
            0, 255, 0, 64
          ]
        end
      end
    end
  end

  def handle_cell_click hpos, vpos
    if hpos > -1 && hpos < @grid_divisions && vpos > -1 && vpos < @grid_divisions then
      if @state == :seeking_first_token then
        if @cells[hpos][vpos].state.nil? then
          @cells[hpos][vpos].state = :first_token
          @cells[hpos][vpos].sprite.angle = -45
          set_state(:seeking_second_token)
          @first_token = @cells[hpos][vpos]
          @first_token_coords = [ hpos, vpos ]
        else
          # reserved for future use; cells that can't be selected?
        end
      elsif @state == :seeking_second_token then
        # but if they re-select the first token, let's start over
        if @cells[hpos][vpos].state == :first_token then
          @cells[hpos][vpos].state = nil # de-select
          @cells[hpos][vpos].sprite.angle = 0
          set_state(:seeking_first_token)
          @first_token = nil
          @first_token_coords = nil
        # make sure the proposed second token is adjacent to the first
        elsif (@first_token_coords[0] - hpos).abs < 2 && (@first_token_coords[1] - vpos).abs < 2 && @cells[hpos][vpos].state.nil? then
          @cells[hpos][vpos].state = :second_token
          @cells[hpos][vpos].sprite.angle = -45
          set_state(:testing_swap)
          @second_token = @cells[hpos][vpos]
          @second_token_coords = [ hpos, vpos ]
        else
          # reserved for future use; cells that can't be selected?
        end
      else
        # game is in a state where selection should be disabled
      end
    end
  end

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

  def handle_mouse
    if @gtk_mouse.down then
      @mouse_down = true
      hpos = x2hpos @gtk_mouse.x
      vpos = y2vpos @gtk_mouse.y
      handle_cell_click hpos, vpos
    end
    if @gtk_mouse.up then
      @mouse_down = false
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
                hpos2x(hpos),
                vpos2y(vpos),
                @grid_segment_size,
                @grid_segment_size
              )
            else
              @cells[hpos][vpos] = temp[hpos][vpos]
              @cells[hpos][vpos].rebuild(
                hpos2x(hpos),
                vpos2y(vpos),
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
                hpos2x(hpos),
                vpos2y(vpos),
                @grid_segment_size,
                @grid_segment_size
              )
            else
              @cells[hpos][vpos] = temp[hpos][vpos]
              @cells[hpos][vpos].rebuild(
                hpos2x(hpos),
                vpos2y(vpos),
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
                hpos2x(hpos),
                vpos2y(vpos),
                @grid_segment_size,
                @grid_segment_size
              )
            else
              @cells[hpos][vpos] = @saved[hpos][vpos].rebuild(
                hpos2x(hpos),
                vpos2y(vpos),
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
      if truth == :back_slash then
        @first_token.sprite.angle = 0
        @first_token.state = nil
        @second_token.sprite.angle = 0
        @second_token.state = nil
        @first_token = nil
        @first_token_coords = nil
        @second_token = nil
        @second_token_coords = nil
        set_state(:seeking_first_token)
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
    handle_mouse # if [:first_token,:second_token].include? @state
    handle_keyboard
    render_grid
    render_cells
    render_right_pane
    if @audio then
    end
    #test_swap if @state == :testing_swap
  end
end

def tick args
  args.state.game ||= Game.new args
  args.state.game.tick
end
