class Game

  attr_accessor :cells, :next_cells # for debugging: $gtk.args.state.game.cells

  GRID_DIVISIONS = 64
  TEXT_HEIGHT = 18

  def initialize args

    $gtk.set_window_title 'Game of Life'

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

    @cells = Array.new(GRID_DIVISIONS){Array.new(GRID_DIVISIONS,false)}
    @next_cells = Array.new(GRID_DIVISIONS){Array.new(GRID_DIVISIONS,true)}
    @run_simulation = false
    @iterate_once = false
    @iteration = 0
    @sparkle = false

    static_render
  end

  def serialize
    {}
  end

  def inspect
    serialize.to_s
  end

  def to_s
    serialize.to_s
  end

  def static_render
    @grid_segment_size = @h.idiv(GRID_DIVISIONS)
    @grid_offset = [
      @lx + (@w - (@grid_segment_size*GRID_DIVISIONS)).half,
      @ly + @grid_segment_size.half
    ]
    GRID_DIVISIONS.times do |x|
      GRID_DIVISIONS.times do |y|
        @gtk_outputs.static_borders << [
          @grid_offset[0] + (@grid_segment_size * x),
          @grid_offset[1] + (@grid_segment_size * y),
          @grid_segment_size,
          @grid_segment_size,
          0, 0, 0, 64
        ]
      end
    end
    @gtk_outputs.static_labels << [@lx,@uy-TEXT_HEIGHT*1,'Mouse to toggle cells']
    @gtk_outputs.static_labels << [@lx,@uy-TEXT_HEIGHT*2,'Space to toggle simulation']
    @gtk_outputs.static_labels << [@lx,@uy-TEXT_HEIGHT*3,'I for one iteration']
    @gtk_outputs.static_labels << [@lx,@uy-TEXT_HEIGHT*4,'C to clear cells']
    @gtk_outputs.static_labels << [@lx,@uy-TEXT_HEIGHT*5,'R to randomize cells']
    @gtk_outputs.static_labels << [@lx,@uy-TEXT_HEIGHT*6,'S for sparkle party']
  end

  def render
    @cells.each_with_index do |row, hpos|
      row.each_with_index do |cell, vpos|
        if cell then
          @gtk_outputs.solids << [
            @grid_offset[0] + (@grid_segment_size * hpos),
            @grid_offset[1] + (@grid_segment_size * vpos),
            @grid_segment_size,
            @grid_segment_size,
            @sparkle ? rand(256) : 0,
            @sparkle ? rand(256) : 0,
            @sparkle ? rand(256) : 0,
            @sparkle ? rand(128) + 128 : 128,
          ]
        end
      end
    end
  end

  def handle_mouse
    if @gtk_mouse.down || @mouse_down then
      @mouse_down = true
      x = @gtk_mouse.x - @grid_offset[0]
      y = @gtk_mouse.y - @grid_offset[1]
      hpos = x.idiv(@grid_segment_size)
      vpos = y.idiv(@grid_segment_size)
      if hpos > -1 && hpos < 64 && vpos > -1 && vpos < 64 && !(hpos == @prev_hpos && vpos == @prev_vpos) then
        @iteration = 0
        @prev_hpos = hpos
        @prev_vpos = vpos
        @cells[hpos][vpos] = !@cells[hpos][vpos]
      end
    end
    if @gtk_mouse.up then
      @mouse_down = false
      @prev_hpos = nil
      @prev_vpos = nil
    end
  end

  def handle_keyboard
    @gtk_kb.key_down.truthy_keys.each do |truth|
      @sparkle = !@sparkle if truth == :s
      if truth == :c then
        @cells = Array.new(GRID_DIVISIONS){Array.new(GRID_DIVISIONS,false)}
        @iteration = 0
      end
      if truth == :r then
        @cells = Array.new(GRID_DIVISIONS){Array.new(GRID_DIVISIONS,false)}
        @cells.each_with_index do |row, hpos|
          row.each_with_index do |cell, vpos|
            @cells[hpos][vpos] = rand(11) > 5
          end
        end
        @iteration = 0
      end
      if truth == :i then
        @iterate_once = !@iterate_once
        @run_simulation = true
      end
      @run_simulation = !@run_simulation if truth == :space
    end
  end

  def wrap pos
    return GRID_DIVISIONS - 1 if pos < 0
    return 0 if pos > GRID_DIVISIONS - 1
    return pos
  end

  def simulation
    if @iterate_once then
      @run_simulation = false
      @iterate_once = false
    end
    @iteration += 1
    @cells.each_with_index do |row, hpos|
      row.each_with_index do |cell, vpos|
        n = {} # neighbors; imagine a number pad: 5 is our center cell
        n[1] = @cells[wrap(hpos-1)][wrap(vpos-1)]
        n[2] = @cells[hpos][wrap(vpos-1)]
        n[3] = @cells[wrap(hpos+1)][wrap(vpos-1)]
        n[4] = @cells[wrap(hpos-1)][vpos]
        n[6] = @cells[wrap(hpos+1)][vpos]
        n[7] = @cells[wrap(hpos-1)][wrap(vpos+1)]
        n[8] = @cells[hpos][wrap(vpos+1)]
        n[9] = @cells[wrap(hpos+1)][wrap(vpos+1)]
        live_count = 0
        n.each_with_index { |e,idx| live_count += 1 if n[idx] }
        @next_cells[hpos][vpos] = @cells[hpos][vpos]
        if @cells[hpos][vpos] then # currently alive
          if live_count == 2 || live_count == 3 then
            # yay, stays alive
          else
            @next_cells[hpos][vpos] = false # dies
          end
        else # currently dead
          if live_count == 3 then
            @next_cells[hpos][vpos] = true # resurrected
          else
            # stays dead
          end
        end
      end
    end
    temp = @cells
    @cells = @next_cells
    @next_cells = temp
  end

  def tick
    @gtk_outputs.labels << [ @lx, @uy, "Iteration #{@iteration}" ]
    handle_mouse if !@run_simulation
    handle_keyboard
    simulation if @run_simulation
    render
  end

end
def tick args
  args.state.game ||= Game.new args
  args.state.game.tick
end
