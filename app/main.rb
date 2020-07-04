class Game

  # for debugging: $gtk.args.state.game.cells, etc
  attr_accessor :cells, :next_cells, :delay, :ruleA, :ruleB, :ruleC

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

    @ruleA = 2
    @ruleB = 3
    @ruleC = 3

    @deaths = 0
    @births = 0

    @cells = Array.new(@grid_divisions){Array.new(@grid_divisions,false)}
    @next_cells = Array.new(@grid_divisions){Array.new(@grid_divisions,true)}
    @run_simulation = false
    @iterate_once = false
    @iteration = 0
    @sparkle = false
    @pulsate = false
    @audio = false

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
    #                                                      Right Mouse for immortal
    #                                                      Middle Mouse (or Z) for pit
    #                                                      Space to toggle simulation
    @gtk_outputs.static_labels << [@lx,@uy-TEXT_HEIGHT*6, '(auto save on start)']
    @gtk_outputs.static_labels << [@lx,@uy-TEXT_HEIGHT*7, '1 for one iteration']
    @gtk_outputs.static_labels << [@lx,@uy-TEXT_HEIGHT*8, 'C to clear cells']
    @gtk_outputs.static_labels << [@lx,@uy-TEXT_HEIGHT*9, 'R to randomize cells']
    @gtk_outputs.static_labels << [@lx,@uy-TEXT_HEIGHT*10, ']/[ for grid size']
    @gtk_outputs.static_labels << [@lx,@uy-TEXT_HEIGHT*11,'(affects performance)']
    @gtk_outputs.static_labels << [@lx,@uy-TEXT_HEIGHT*12,',/. for simulation delay']
    @gtk_outputs.static_labels << [@lx,@uy-TEXT_HEIGHT*13,'(slow down if frame skipping)']
    @gtk_outputs.static_labels << [@lx,@uy-TEXT_HEIGHT*14,'7/8/u/i/j/k for rule tweaks']
    @gtk_outputs.static_labels << [@lx,@uy-TEXT_HEIGHT*15,'3/4 to save/restore grid']
    @gtk_outputs.static_labels << [@lx,@uy-TEXT_HEIGHT*16,'6 to restore auto save']
    @gtk_outputs.static_labels << [@lx,@uy-TEXT_HEIGHT*17,'A to toggle audio']
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
        color = [
            @sparkle ? rand(256) : @pulsate ? color_wrap(@gtk_args.tick_count.mod(64)) : 0,
            @sparkle ? rand(256) : @pulsate ? color_wrap(@gtk_args.tick_count.mod(64))*2 : 0,
            @sparkle ? rand(256) : @pulsate ? color_wrap(@gtk_args.tick_count.mod(64))*3 : 0,
        ]
        if cell == :immortal then
          color[0] = @sparkle ? rand(256) : @pulsate ? color_wrap(@gtk_args.tick_count.mod(64)) + 128 : 128
          color[1] = 0
          color[2] = 0
        end
        if [:immortal,:normal].include? cell then
          @gtk_outputs.solids << [
            @grid_offset[0] + (@grid_segment_size * hpos),
            @grid_offset[1] + (@grid_segment_size * vpos),
            @grid_segment_size,
            @grid_segment_size,
            color,
            cell == :immortal ? 255 : 128
          ]
        elsif cell == :pit then
          @gtk_outputs.lines << [
            @grid_offset[0] + (@grid_segment_size * hpos),
            @grid_offset[1] + (@grid_segment_size * vpos),
            @grid_offset[0] + (@grid_segment_size * hpos) + @grid_segment_size,
            @grid_offset[1] + (@grid_segment_size * vpos) + @grid_segment_size,
            0, 0, 0
          ]
          @gtk_outputs.lines << [
            @grid_offset[0] + (@grid_segment_size * hpos),
            @grid_offset[1] + (@grid_segment_size * vpos) + @grid_segment_size,
            @grid_offset[0] + (@grid_segment_size * hpos) + @grid_segment_size,
            @grid_offset[1] + (@grid_segment_size * vpos),
            0, 0, 0
          ]
        end
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
      if @cells[hpos][vpos] then
        @cells[hpos][vpos] = false
      else
        @cells[hpos][vpos] = cell_type
      end
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
      if truth == :z then
        handle_cell_toggle :pit, true
      end
      if truth == :space then
        @run_simulation = !@run_simulation
        if @run_simulation then
          @auto_saved = Array.new(@grid_divisions){Array.new(@grid_divisions,true)}
          @cells.each_with_index do |row, hpos|
            row.each_with_index do |cell, vpos|
              @auto_saved[hpos][vpos] = @cells[hpos][vpos]
            end
          end
        end
      end
      if truth == :one then
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
            @cells[hpos][vpos] = rand(11) > 5 ? :normal : false
          end
        end
        @iteration = 0
      end
      if truth == :s
        @sparkle = !@sparkle
      end
      if truth == :p
        @pulsate = !@pulsate
      end
      if truth == :close_square_brace then
        @grid_divisions += 1
        @next_cells = Array.new(@grid_divisions){Array.new(@grid_divisions,true)}
        temp = @cells
        @cells = Array.new(@grid_divisions){Array.new(@grid_divisions,false)}
        @cells.each_with_index do |row, hpos|
          row.each_with_index do |cell, vpos|
            if temp[hpos].nil? then
              @cells[hpos][vpos] = false
            else
              @cells[hpos][vpos] = temp[hpos][vpos]
            end
          end
        end
        @iteration = 0
      end
      if truth == :open_square_brace then
        @grid_divisions -= 1
        @grid_divisions = 1 if @grid_divisions < 1
        @next_cells = Array.new(@grid_divisions){Array.new(@grid_divisions,true)}
        temp = @cells
        @cells = Array.new(@grid_divisions){Array.new(@grid_divisions,false)}
        @cells.each_with_index do |row, hpos|
          row.each_with_index do |cell, vpos|
            if temp[hpos].nil? then
              @cells[hpos][vpos] = false
            else
              @cells[hpos][vpos] = temp[hpos][vpos]
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
      if truth == :seven then
        @ruleA -= 1
        @ruleA = 0 if @ruleA < 0
      end
      if truth == :eight then
        @ruleA += 1
      end
      if truth == :u then
        @ruleB -= 1
        @ruleB = 0 if @ruleB < 0
      end
      if truth == :i then
        @ruleB += 1
      end
      if truth == :j then
        @ruleC -= 1
        @ruleC = 0 if @ruleC < 0
      end
      if truth == :k then
        @ruleC += 1
      end
      if truth == :three && !@saved.nil? then # restore
        @iteration = 0
        @cells.each_with_index do |row, hpos|
          row.each_with_index do |cell, vpos|
            if @saved[hpos].nil? then
              @cells[hpos][vpos] = false
            else
              @cells[hpos][vpos] = @saved[hpos][vpos]
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
      if truth == :six && !@auto_saved.nil? then # restore auto save
        @iteration = 0
        @cells.each_with_index do |row, hpos|
          row.each_with_index do |cell, vpos|
            if @auto_saved[hpos].nil? then
              @cells[hpos][vpos] = false
            else
              @cells[hpos][vpos] = @auto_saved[hpos][vpos]
            end
          end
        end
      end
      if truth == :a
        @audio = !@audio
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
        live_count = 0
        # imagine a number pad: 5 is our center cell
        live_count +=1 if [:immortal,:normal].include? @cells[wrap(hpos-1)][wrap(vpos-1)]  # 1
        live_count +=1 if [:immortal,:normal].include? @cells[hpos][wrap(vpos-1)]          # 2
        live_count +=1 if [:immortal,:normal].include? @cells[wrap(hpos+1)][wrap(vpos-1)]  # 3
        live_count +=1 if [:immortal,:normal].include? @cells[wrap(hpos-1)][vpos]          # 4
        live_count +=1 if [:immortal,:normal].include? @cells[wrap(hpos+1)][vpos]          # 6
        live_count +=1 if [:immortal,:normal].include? @cells[wrap(hpos-1)][wrap(vpos+1)]  # 7
        live_count +=1 if [:immortal,:normal].include? @cells[hpos][wrap(vpos+1)]          # 8
        live_count +=1 if [:immortal,:normal].include? @cells[wrap(hpos+1)][wrap(vpos+1)]  # 9
        @next_cells[hpos][vpos] = @cells[hpos][vpos]
        if @cells[hpos][vpos] == :immortal || @cells[hpos][vpos] == :pit then
          # immortal cells do not die
          # pit cells do not live
        else
          # normal life rules
          if @cells[hpos][vpos] then # currently alive
            if live_count == @ruleA || live_count == @ruleB then
              # yay, stays alive
            else
              @next_cells[hpos][vpos] = false # dies
              no_change = false
              @deaths += 1
            end
          else # currently dead
            if live_count == @ruleC then
              @next_cells[hpos][vpos] = :normal # resurrected
              no_change = false
              @births += 1
            else
              # stays dead
            end
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

  def render_right_pane
    @gtk_outputs.labels << [ @grid_offset[0]+(@grid_segment_size*@grid_divisions), @uy,               'Cell rules:' ]
    #                                                                                                 '1234567890123456789012345678' ]
    @gtk_outputs.labels << [ @grid_offset[0]+(@grid_segment_size*@grid_divisions), @uy-TEXT_HEIGHT*2, "1) Live cells with #{@ruleA} or #{@ruleB}" ]
    @gtk_outputs.labels << [ @grid_offset[0]+(@grid_segment_size*@grid_divisions), @uy-TEXT_HEIGHT*3, '   live neighbours survive.' ]
    @gtk_outputs.labels << [ @grid_offset[0]+(@grid_segment_size*@grid_divisions), @uy-TEXT_HEIGHT*4, "2) Dead cells with #{@ruleC} live" ]
    @gtk_outputs.labels << [ @grid_offset[0]+(@grid_segment_size*@grid_divisions), @uy-TEXT_HEIGHT*5, '   neighbours return to life' ]
    @gtk_outputs.labels << [ @grid_offset[0]+(@grid_segment_size*@grid_divisions), @uy-TEXT_HEIGHT*6, '3) All other live cells die.' ]
    @gtk_outputs.labels << [ @grid_offset[0]+(@grid_segment_size*@grid_divisions), @uy-TEXT_HEIGHT*7, '   All other dead cells stay' ]
    @gtk_outputs.labels << [ @grid_offset[0]+(@grid_segment_size*@grid_divisions), @uy-TEXT_HEIGHT*8, '   dead' ]
    @gtk_outputs.labels << [ @grid_offset[0]+(@grid_segment_size*@grid_divisions), @uy-TEXT_HEIGHT*10,'These rules are applied to' ]
    @gtk_outputs.labels << [ @grid_offset[0]+(@grid_segment_size*@grid_divisions), @uy-TEXT_HEIGHT*11,'all cells at the same time.']
    @gtk_outputs.labels << [ @grid_offset[0]+(@grid_segment_size*@grid_divisions), @uy-TEXT_HEIGHT*13,'Deviations:']
    #                                                                                                 '1234567890123456789012345678' ]
    @gtk_outputs.labels << [ @grid_offset[0]+(@grid_segment_size*@grid_divisions), @uy-TEXT_HEIGHT*15,'Immortal cells live forever.' ]
    @gtk_outputs.labels << [ @grid_offset[0]+(@grid_segment_size*@grid_divisions), @uy-TEXT_HEIGHT*16,'Pit cells never live.' ]
    @gtk_outputs.labels << [ @grid_offset[0]+(@grid_segment_size*@grid_divisions), @uy-TEXT_HEIGHT*17,'Play area is finite & wraps.' ]
    @gtk_outputs.labels << [ @grid_offset[0]+(@grid_segment_size*@grid_divisions), @uy-TEXT_HEIGHT*19,'Audio:']
    @gtk_outputs.labels << [ @grid_offset[0]+(@grid_segment_size*@grid_divisions), @uy-TEXT_HEIGHT*21,'births>deaths => 1000 Hz']
    @gtk_outputs.labels << [ @grid_offset[0]+(@grid_segment_size*@grid_divisions), @uy-TEXT_HEIGHT*22,'deaths>births => 2000 Hz']
    @gtk_outputs.labels << [ @grid_offset[0]+(@grid_segment_size*@grid_divisions), @uy-TEXT_HEIGHT*23,'deaths=births => no sound']
  end

  def tick
    @gtk_outputs.labels << [@lx, @uy, "Iteration #{@iteration}", @run_simulation ? [0,0,0] : [255,0,0]]
    @gtk_outputs.labels << [@lx,@uy-TEXT_HEIGHT*1,"Grid #{@grid_divisions}x#{@grid_divisions} Delay #{@delay}"]
    @gtk_outputs.labels << [@lx,@uy-TEXT_HEIGHT*2,'Left Mouse to toggle cells', @run_simulation ? [255,0,0] : [0,0,0]]
    @gtk_outputs.labels << [@lx,@uy-TEXT_HEIGHT*3,'Right Mouse for immortal', @run_simulation ? [255,0,0] : [0,0,0]]
    @gtk_outputs.labels << [@lx,@uy-TEXT_HEIGHT*4,'Middle Mouse (or Z) for pit', @run_simulation ? [255,0,0] : [0,0,0]]
    @gtk_outputs.labels << [@lx,@uy-TEXT_HEIGHT*5,'Space to toggle simulation', @run_simulation ? [0,0,0] : [255,0,0]]
    handle_mouse if !@run_simulation
    handle_keyboard
    if @run_simulation
      simulation if @gtk_state.tick_count.mod(@delay) == 0
    end
    render_grid
    render_cells
    render_right_pane
    if @audio then
    #if @gtk_state.tick_count.mod(5) == 0 && @audio then
      if @births > @deaths then
        @gtk_outputs.sounds << 'app/audiocheck.net_sin_1000Hz_-3dBFS_0.1s.wav'
      elsif @births < @deaths
        @gtk_outputs.sounds << 'app/audiocheck.net_sin_2000Hz_-3dBFS_0.1s.wav'
      end
      @births = 0
      @deaths = 0
    end
  end
end

def tick args
  args.state.game ||= Game.new args
  args.state.game.tick
end
