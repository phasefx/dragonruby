class Game

  attr_accessor :cells, :next_cells, :delay # for debugging: $gtk.args.state.game.cells

  TEXT_HEIGHT = 20

  def initialize args

    $gtk.set_window_title 'Game of Life'

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

    @grid_divisions = 32
    @delay = 2

    @cells = Array.new(@grid_divisions){Array.new(@grid_divisions,false)}
    @next_cells = Array.new(@grid_divisions){Array.new(@grid_divisions,true)}
    @run_simulation = false
    @iterate_once = false
    @iteration = 0
    @sparkle = false
    @pulsate = false

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

  def render_grid
    @grid_segment_size = (@h-10)/(@grid_divisions)
    @grid_offset = [
      @lx + 290,
      @ly + 5
    ]
    @grid_divisions.times do |x|
      @grid_divisions.times do |y|
        @gtk_outputs.borders << [
          @grid_offset[0] + (@grid_segment_size * x),
          @grid_offset[1] + (@grid_segment_size * y),
          @grid_segment_size,
          @grid_segment_size,
          0, 0, 0, 64
        ]
      end
    end
  end

  def static_render
    #                                                      Iteration #
    #                                                      Grid #x# Delay #
    #                                                      Left Mouse to toggle cells
    #                                                      Space to toggle simulation
    @gtk_outputs.static_labels << [@lx,@uy-TEXT_HEIGHT*4, 'I for one iteration']
    @gtk_outputs.static_labels << [@lx,@uy-TEXT_HEIGHT*5, 'C to clear cells']
    @gtk_outputs.static_labels << [@lx,@uy-TEXT_HEIGHT*6, 'R to randomize cells']
    @gtk_outputs.static_labels << [@lx,@uy-TEXT_HEIGHT*7, ']/[ for grid size']
    @gtk_outputs.static_labels << [@lx,@uy-TEXT_HEIGHT*8, '(affects performance)']
    @gtk_outputs.static_labels << [@lx,@uy-TEXT_HEIGHT*9, ',/. for simulation delay']
    @gtk_outputs.static_labels << [@lx,@uy-TEXT_HEIGHT*10,'(slow down if frame skipping)']
  end

  def color_wrap c
    if c > 32
      return 64 - c
    else
      c
    end
  end

  def render_cells
    @cells.each_with_index do |row, hpos|
      row.each_with_index do |cell, vpos|
        if cell then
          @gtk_outputs.solids << [
            @grid_offset[0] + (@grid_segment_size * hpos),
            @grid_offset[1] + (@grid_segment_size * vpos),
            @grid_segment_size,
            @grid_segment_size,
            @sparkle ? rand(256) : @pulsate ? color_wrap(@gtk_args.tick_count.mod(64)) : 0,
            @sparkle ? rand(256) : @pulsate ? color_wrap(@gtk_args.tick_count.mod(64))*2 : 0,
            @sparkle ? rand(256) : @pulsate ? color_wrap(@gtk_args.tick_count.mod(64))*3 : 0,
            128
          ]
        end
      end
    end
  end

  def handle_mouse
    if (@gtk_mouse.down && @gtk_mouse.button_left) || @mouse_down then
      puts "1: up = #{@gtk_mouse.up} down = #{@gtk_mouse.down} button_left = #{@gtk_mouse.button_left}"
      @mouse_down = true
      x = @gtk_mouse.x - @grid_offset[0]
      y = @gtk_mouse.y - @grid_offset[1]
      hpos = (x/(@grid_segment_size)).floor
      vpos = (y/(@grid_segment_size)).floor
      if hpos > -1 && hpos < @grid_divisions && vpos > -1 && vpos < @grid_divisions && !(hpos == @prev_hpos && vpos == @prev_vpos) then
        @iteration = 0
        @prev_hpos = hpos
        @prev_vpos = vpos
        @cells[hpos][vpos] = !@cells[hpos][vpos]
      end
    end
    if @gtk_mouse.up then
      puts "2: up = #{@gtk_mouse.up} down = #{@gtk_mouse.down} button_left = #{@gtk_mouse.button_left}"
      @mouse_down = false
      @prev_hpos = nil
      @prev_vpos = nil
    end
  end

  def handle_keyboard
    @gtk_kb.key_down.truthy_keys.each do |truth|
      if truth == :space then
        @run_simulation = !@run_simulation
      end
      if truth == :i then
        @iterate_once = !@iterate_once
        @run_simulation = true
      end
      if truth == :c then
        @cells = Array.new(@grid_divisions){Array.new(@grid_divisions,false)}
        @next_cells = Array.new(@grid_divisions){Array.new(@grid_divisions,true)}
        @iteration = 0
      end
      if truth == :r then
        @cells = Array.new(@grid_divisions){Array.new(@grid_divisions,false)}
        @next_cells = Array.new(@grid_divisions){Array.new(@grid_divisions,true)}
        @cells.each_with_index do |row, hpos|
          row.each_with_index do |cell, vpos|
            @cells[hpos][vpos] = rand(11) > 5
          end
        end
        @iteration = 0
      end
      if truth == :s
        @sparkle = !@sparkle if truth
      end
      if truth == :p
        @pulsate = !@pulsate if truth
      end
      if truth == :close_square_brace then
        @grid_divisions += 1
        @cells = Array.new(@grid_divisions){Array.new(@grid_divisions,false)}
        @next_cells = Array.new(@grid_divisions){Array.new(@grid_divisions,true)}
        @iteration = 0
      end
      if truth == :open_square_brace then
        @grid_divisions -= 1
        @grid_divisions = 1 if @grid_divisions < 1
        @cells = Array.new(@grid_divisions){Array.new(@grid_divisions,false)}
        @next_cells = Array.new(@grid_divisions){Array.new(@grid_divisions,true)}
        @iteration = 0
      end
      if truth == :comma then
        @delay -= 1
        @delay = 1 if @delay < 1
      end
      if truth == :period then
        @delay += 1
      end
    end
  end

  def wrap pos
    return @grid_divisions - 1 if pos < 0
    return 0 if pos > @grid_divisions - 1
    return pos
  end

  def simulation
    if @iterate_once then
      @run_simulation = false
      @iterate_once = false
    end
    @iteration += 1
    no_change = true
    @cells.each_with_index do |row, hpos|
      row.each_with_index do |cell, vpos|
        puts "examining (#{hpos},#{vpos})" if @gtk_state.debug # set through console
        live_count = 0
        # imagine a number pad: 5 is our center cell
        live_count +=1 if @cells[wrap(hpos-1)][wrap(vpos-1)]  # 1
        live_count +=1 if @cells[hpos][wrap(vpos-1)]          # 2
        live_count +=1 if @cells[wrap(hpos+1)][wrap(vpos-1)]  # 3
        live_count +=1 if @cells[wrap(hpos-1)][vpos]          # 4
        live_count +=1 if @cells[wrap(hpos+1)][vpos]          # 6
        live_count +=1 if @cells[wrap(hpos-1)][wrap(vpos+1)]  # 7
        live_count +=1 if @cells[hpos][wrap(vpos+1)]          # 8
        live_count +=1 if @cells[wrap(hpos+1)][wrap(vpos+1)]  # 9
        @next_cells[hpos][vpos] = @cells[hpos][vpos]
        if @cells[hpos][vpos] then # currently alive
          if live_count == 2 || live_count == 3 then
            # yay, stays alive
          else
            @next_cells[hpos][vpos] = false # dies
            no_change = false
          end
        else # currently dead
          if live_count == 3 then
            @next_cells[hpos][vpos] = true # resurrected
            no_change = false
          else
            # stays dead
          end
        end
      end
    end
    if no_change then
      @run_simulation = false
      puts "no change detected, simulation paused"
    end
    @cells, @next_cells = @next_cells, @cells
  end

  def tick
    @gtk_outputs.labels << [@lx, @uy, "Iteration #{@iteration}", @run_simulation ? [0,0,0] : [255,0,0]]
    @gtk_outputs.labels << [@lx,@uy-TEXT_HEIGHT*1,"Grid #{@grid_divisions}x#{@grid_divisions} Delay #{@delay}"]
    @gtk_outputs.labels << [@lx,@uy-TEXT_HEIGHT*2,'Left Mouse to toggle cells', @run_simulation ? [255,0,0] : [0,0,0]]
    @gtk_outputs.labels << [@lx,@uy-TEXT_HEIGHT*3,'Space to toggle simulation', @run_simulation ? [0,0,0] : [255,0,0]]
    handle_mouse if !@run_simulation
    handle_keyboard
    if @run_simulation
      simulation if @gtk_state.tick_count.mod(@delay) == 0
    end
    render_grid
    render_cells
  end

end
def tick args
  args.state.game ||= Game.new args
  args.state.game.tick
  if args.state.slowmo then # set through console
    $gtk.sleep args.state.slowmo_speed || 0.1
  end
end
