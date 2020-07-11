class Game

  # for debugging: $gtk.args.state.game.cells, etc
  attr_accessor :cells, :state, :audio, :audio_scheme

  INITIAL_GRID_SIZE = 7
  TEXT_HEIGHT = 20
  SHRINK_SPEED = 5
  DROP_SPEED = 10
  # we have 34 icons; we can use these to mix things up a bit
  FAVORITE_TILES = [1,2,3,4,5,8,9,10]
  UNIQUE_TILES = 7
  TILESHIFT = rand(2)
  # FAVORITE_TILES[rand(UNIQUE_TILES) + TILESHIFT]

  def initialize args

    @debug = false

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

    @grid_divisions = INITIAL_GRID_SIZE
    @delay = 1

    set_state(:seeking_first_token)
    #        :seeking_second_token
    #        :testing_swap
    #        :clearing_matches
    #        :clear_animation
    #        :drop_pieces
    #        :pieces_dropping

    @combo_count = 0
    @score_multiplier = 0
    @current_combo = 0
    @last_combo = 0
    @highest_combo = 0
    @score_for_this_cycle = 0
    @score_for_last_cycle = 0
    @total_score = 0

    @cells = Array.new(@grid_divisions){Array.new(@grid_divisions,false)}
    @audio = true
    @audio_scheme = :indexed

    render_grid # do this now so that we have @grid_segment_size ready for init_cells
    init_cells
    static_render
    if clearing_matches then
      set_state(:clear_animation)
      @animation_count = 0
    end
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
    puts "stage change: #{@state} to #{s}" if @debug
    @state = s
  end

  def match_sound celltype
    puts "match_sound #{celltype} with #{@audio_scheme}" if @debug
    case @audio_scheme
    when :random then random_sound
    when :indexed then indexed_sound FAVORITE_TILES.index(celltype)
    end
  end

  def indexed_sound idx
    return if !@audio
    puts "playing sound #{idx}" if @debug
    case idx
    when 0 then @gtk_outputs.sounds << 'media/sfx/A3.wav'
    when 1 then @gtk_outputs.sounds << 'media/sfx/B3.wav'
    when 2 then @gtk_outputs.sounds << 'media/sfx/C3.wav'
    when 3 then @gtk_outputs.sounds << 'media/sfx/C4.wav'
    when 4 then @gtk_outputs.sounds << 'media/sfx/D3.wav'
    when 5 then @gtk_outputs.sounds << 'media/sfx/E3.wav'
    when 6 then @gtk_outputs.sounds << 'media/sfx/F3.wav'
    else @gtk_outputs.sounds << 'media/sfx/G3.wav'
    end
  end

  def random_sound
    return if !@audio
    puts "playing random sound" if @debug
    indexed_sound rand(8)
  end

  def clash_sound
    return if !@audio
    puts "playing all sounds" if @debug
    (0..7).each do |idx|
      indexed_sound idx
    end
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
    attr_accessor :x, :y, :w, :h, :type, :state, :match_state, :dropping, :sprite, :target_x, :target_y

    def initialize x, y, w, h, type=nil
      @x = x
      @y = y
      @w = w
      @h = h
      @type = type.nil? ? FAVORITE_TILES[rand(UNIQUE_TILES) + TILESHIFT] : type
      puts "bad tile selection #{@type}" if ! FAVORITE_TILES.include? @type
      @dropping = false
      #@match_state = false
      #@state = nil
      @sprite = Sprite.new(@x,@y,@w,@h,@type)
    end

    # need to look into .dup and .clone, but for now...
    def copy
      Book.new(@x,@y,@w,@h,@type)
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

    def drop_to x, y
      @target_x = x
      @target_y = y
      @dropping = true
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

  def rebuild_cells
    @cells.each_with_index do |row, hpos|
      row.each_with_index do |cell, vpos|
        @cells[hpos][vpos].rebuild(
          hpos2x(hpos),
          vpos2y(vpos),
          @grid_segment_size,
          @grid_segment_size
        )
      end
    end
  end

  def remove_matches
    found = false
    @cells.each_with_index do |row, hpos|
      row.each_with_index do |cell, vpos|
        next if @cells[hpos][vpos].nil?
        if @cells[hpos][vpos].match_state then
          @cells[hpos][vpos] = nil
          found = true
        end
      end
    end
    set_state(:drop_pieces)
    return found
  end

  def test_for_nils
    found = false
    @cells.each_with_index do |row, hpos|
      row.each_with_index do |cell, vpos|
        found = true if @cells[hpos][vpos].nil?
      end
    end
    return found
  end

  def drop_pieces
    set_state(:pieces_dropping) if test_for_nils
    while test_for_nils do
    #if true then
      @cells.each_with_index do |row, hpos|
        row.each_with_index do |cell, vpos|
          #puts "hpos = #{hpos} vpos = #{vpos} cell = #{@cells[hpos][vpos]}"
          if @cells[hpos][vpos].nil? then
            if wrap(vpos+1) > vpos then
              #puts "found cell above, #{@cells[hpos][wrap(vpos+1)].class}"
              # we can reference the cell above; drop it here
              @cells[hpos][vpos] = @cells[hpos][wrap(vpos+1)].nil? ? nil : @cells[hpos][wrap(vpos+1)].drop_to(
                hpos2x(hpos),
                vpos2y(vpos)
              )
              @cells[hpos][wrap(vpos+1)] = nil
            else
              #puts "already at top"
              # we are at the top, make a new Book
              @cells[hpos][vpos] = Book.new(
                hpos2x(hpos),
                vpos2y(vpos+1),
                @grid_segment_size,
                @grid_segment_size
              ).drop_to(
                hpos2x(hpos),
                vpos2y(vpos)
              )
            end # of position test
            #puts "new cell = #{@cells[hpos][vpos]}"
          end # of nil test
        end # of row.each_with_index
      end # of @cells.each_with_index
    end # of while test_for_nils
  end

  def render_cells
    if @state == :clear_animation then
      @animation_count += 1
      if @animation_count >= @grid_segment_size.div(SHRINK_SPEED) then
        set_state(:remove_matches)
      end
    end
    pieces_dropping = false
    @cells.each_with_index do |row, hpos|
      row.each_with_index do |cell, vpos|
        cell = @cells[hpos][vpos]
        @gtk_outputs.labels << [ hpos2x(hpos), vpos2y(vpos) + TEXT_HEIGHT, "#{hpos}, #{vpos}" ] if @debug
        @gtk_outputs.labels << [ hpos2x(hpos), vpos2y(vpos) + @grid_segment_size, "#{cell.nil? ? 'nil' : cell.type}" ] if @debug
        next if cell.nil?
        if cell.match_state && @state == :clear_animation then
          cell.sprite.angle = @gtk_args.tick_count.mod(360)*10
          cell.sprite.x += SHRINK_SPEED.half
          cell.sprite.y += SHRINK_SPEED.half
          cell.sprite.w -= SHRINK_SPEED
          cell.sprite.w = 1 if cell.sprite.w < 1
          cell.sprite.h -= SHRINK_SPEED
          cell.sprite.h = 1 if cell.sprite.h < 1
        end
        if @state == :pieces_dropping && cell.dropping then
          cell.sprite.y -= DROP_SPEED
          if cell.sprite.y <= cell.target_y then
            cell.dropping = false
            cell.target_x = nil
            cell.target_y = nil
          else
            pieces_dropping = true
          end
        end
        if @state == :seeking_second_token && cell.state == :first_token && @mouse_down then
          adjust_x = @mouse_down_initial_x - hpos2x(@mouse_down_initial_hpos)
          adjust_y = @mouse_down_initial_y - vpos2y(@mouse_down_initial_vpos)
          #puts "floating book at #{@gtk_mouse.x}, #{@gtk_mouse.y} adjusted by #{adjust_x}, #{adjust_y}"
          floating_book = cell.copy.rebuild(
            @gtk_mouse.x - adjust_x,
            @gtk_mouse.y - adjust_y,
            @grid_segment_size,
            @grid_segment_size
          )
          @gtk_outputs.primitives << floating_book.sprite
        else
          @gtk_outputs.sprites << cell.sprite
        end
        if cell.state == :first_token then
          @gtk_outputs.solids << [
            hpos2x(hpos),
            vpos2y(vpos),
            @grid_segment_size,
            @grid_segment_size,
            0, 0, 255, 64
          ]
        elsif cell.state == :second_token then
          @gtk_outputs.solids << [
            hpos2x(hpos),
            vpos2y(vpos),
            @grid_segment_size,
            @grid_segment_size,
            0, 255, 0, 64
          ]
        end # of token highlighting
      end # of row.each_with_index
    end # @cells.each_with_index
    if @state == :pieces_dropping && !pieces_dropping then
      if clearing_matches then
        old_combo = @current_combo
        @combo_count += 1
        if @combo_count == 1 then
          @current_combo += @score_for_last_cycle
        end
        @current_combo += @score_for_this_cycle
        puts "combo count = #{@combo_count} current_combo was #{old_combo}, but is now #{@current_combo}" if @debug
        set_state(:clear_animation)
        @animation_count = 0
      else
        puts "end of combo, current_combo = #{@current_combo}" if @debug
        @last_combo = @current_combo
        @highest_combo = @current_combo if @current_combo > @highest_combo
        @current_combo = 0
        @combo_count = 0
        set_state(:seeking_first_token)
      end
    elsif @state != :pieces_dropping && pieces_dropping then
      set_state(:pieces_dropping)
    end
  end

  def handle_cell_click hpos, vpos, entry_state
    # return true for valid cells
    puts "inside handle_cell_click #{hpos}, #{vpos} during #{@state}" if @debug
    if hpos > -1 && hpos < @grid_divisions && vpos > -1 && vpos < @grid_divisions then
      return false if @cells[hpos][vpos].nil? # shouldn't happen once dev is finished
      if @state == :seeking_first_token then
        if @cells[hpos][vpos].state.nil? then
          @cells[hpos][vpos].state = :first_token
          @cells[hpos][vpos].sprite.angle = -45
          set_state(:seeking_second_token)
          @first_token = @cells[hpos][vpos]
          @first_token_coords = [ hpos, vpos ]
          return true
        else
          # reserved for future use; cells that can't be selected?
          return false
        end
      elsif @state == :seeking_second_token then
        # but if they re-select the first token, let's start over (unless doing drag & drop)
        if entry_state == :mouse_down && @cells[hpos][vpos].state == :first_token then
          @cells[hpos][vpos].state = nil # de-select
          @cells[hpos][vpos].sprite.angle = 0
          set_state(:seeking_first_token)
          @first_token = nil
          @first_token_coords = nil
          return true
        # make sure the proposed second token is adjacent to the first
        elsif (@first_token_coords[0] - hpos).abs < 2 && (@first_token_coords[1] - vpos).abs < 2 && @cells[hpos][vpos].state.nil? then
          @cells[hpos][vpos].state = :second_token
          @cells[hpos][vpos].sprite.angle = -45
          set_state(:testing_swap)
          @second_token = @cells[hpos][vpos]
          @second_token_coords = [ hpos, vpos ]
          return true
        elsif entry_state == :mouse_down
          # so second token is too far away, let's make it the new first token (unless doing drag & drop)
          @first_token.state = nil
          @first_token.sprite.angle = 0
          @cells[hpos][vpos].state = :first_token
          @cells[hpos][vpos].sprite.angle = -45
          @first_token = @cells[hpos][vpos]
          @first_token_coords = [ hpos, vpos ]
          return true
        else
          return false
        end
      else
        # game is in a state where selection should be disabled
        return false
      end
    end
    return false
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

  def mouse_down_for_at_least_half_second
    @mouse_down && ((@gtk_args.tick_count - @mouse_down_at)>=30)
  end

  def handle_mouse
    hpos = x2hpos @gtk_mouse.x
    vpos = y2vpos @gtk_mouse.y
    if @gtk_mouse.down then
      puts "inside @gtk_mouse.down; hpos = #{hpos} vpos = #{vpos} hpos2x = #{hpos2x(hpos)} vpos2y = #{vpos2y(vpos)} mouse.x = #{@gtk_mouse.x} mouse.y = #{@gtk_mouse.y}" if @debug
      @mouse_down = true
      @mouse_down_at = @gtk_args.tick_count
      @mouse_down_initial_hpos = hpos
      @mouse_down_initial_vpos = vpos
      @mouse_down_initial_x = @gtk_mouse.x
      @mouse_down_initial_y = @gtk_mouse.y
      handle_cell_click hpos, vpos, :mouse_down
    end
    if @gtk_mouse.up then
      puts "inside @gtk_mouse.up" if @debug
      if hpos != @mouse_down_initial_hpos || vpos != @mouse_down_initial_vpos then
        handle_cell_click(hpos, vpos, :mouse_up)
      end
      @mouse_down = false
      @mouse_down_at = nil
      @mouse_down_initial_hpos = nil
      @mouse_down_initial_vpos = nil
      @mouse_down_initial_x = nil
      @mouse_down_initial_y = nil
    end
  end

  def handle_keyboard
    @gtk_kb.key_down.truthy_keys.each do |truth|
      if truth == :t then # test
        @gtk_outputs.sounds << 'media/sfx/test.wav'
      end
      if truth == :d then # debug toggle
        @debug = !@debug
      end
      if truth == :r then # reset
        @cells = Array.new(@grid_divisions){Array.new(@grid_divisions,false)}
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
        @total_score = 0
        if clearing_matches then
          set_state(:clear_animation)
          @animation_count = 0
        end
      end
      if truth == :close_square_brace then # shrink grid
        @grid_divisions += 1
        @grid_segment_size = (@h-10)/(@grid_divisions)
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
        if clearing_matches then
          set_state(:clear_animation)
          @animation_count = 0
        end
      end
      if truth == :open_square_brace then # grow grid
        @grid_divisions -= 1
        @grid_divisions = 1 if @grid_divisions < 1
        @grid_segment_size = (@h-10)/(@grid_divisions)
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
        if clearing_matches then
          set_state(:clear_animation)
          @animation_count = 0
        end
      end
      if truth == :comma then
        @delay -= 1
        @delay = 1 if @delay < 1
      end
      if truth == :period then
        @delay += 1
      end
      if truth == :three && !@saved.nil? then # restore
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
      if truth == :right then
        @cells = @cells.rotate(1)
        rebuild_cells
        if clearing_matches then
          set_state(:clear_animation)
          @animation_count = 0
        end
      end
      if truth == :left then
        @cells = @cells.rotate(-1)
        rebuild_cells
        if clearing_matches then
          set_state(:clear_animation)
          @animation_count = 0
        end
      end
      if truth == :up then
        @cells.each_with_index do |row, hpos|
          @cells[hpos] = @cells[hpos].rotate(1)
        end
        rebuild_cells
        if clearing_matches then
          set_state(:clear_animation)
          @animation_count = 0
        end
      end
      if truth == :down then
        @cells.each_with_index do |row, hpos|
          @cells[hpos] = @cells[hpos].rotate(-1)
        end
        rebuild_cells
        if clearing_matches then
          set_state(:clear_animation)
          @animation_count = 0
        end
      end
      if truth == :back_slash then
        if !@first_token.nil? then
          @first_token.sprite.angle = 0
          @first_token.state = nil
          @first_token = nil
          @first_token_coords = nil
        end
        if !@second_token.nil? then
          @second_token.sprite.angle = 0
          @second_token.state = nil
          @second_token = nil
          @second_token_coords = nil
        end
        set_state(:seeking_first_token)
      end
    end
  end

  def wrap pos
    return @grid_divisions - 1 if pos < 0
    return 0 if pos > @grid_divisions - 1
    return pos
  end

  def render_text
    #@gtk_outputs.labels << [@lx,@uy-TEXT_HEIGHT*21,'Press Enter for demo']
    #@gtk_outputs.labels << [ @grid_offset[0]+(@grid_segment_size*@grid_divisions), @uy,               'Cell rules:' ]
    ##                                                                                                 '1234567890123456789012345678' ]
    @gtk_outputs.labels << [ @lx,@uy-TEXT_HEIGHT*0,"Score: #{@total_score}" ]
    @gtk_outputs.labels << [ @lx,@uy-TEXT_HEIGHT*1,"Last Combo: #{@last_combo}" ]
    @gtk_outputs.labels << [ @lx,@uy-TEXT_HEIGHT*2,"Highest Combo: #{@highest_combo}" ]

    @gtk_outputs.labels << [ @lx,@uy-TEXT_HEIGHT*4,"Match at least 3" ]
    @gtk_outputs.labels << [ @lx,@uy-TEXT_HEIGHT*5,"R to Reset" ]
    @gtk_outputs.labels << [ @lx,@uy-TEXT_HEIGHT*6,"Arrows to shift grid" ]
    @gtk_outputs.labels << [ @lx,@uy-TEXT_HEIGHT*7,"A to toggle audio" ]
  end

  def undo_swap
    h1 = @first_token_coords[0]
    h2 = @second_token_coords[0]
    v1 = @first_token_coords[1]
    v2 = @second_token_coords[1]
    @cells[h1][v1] = @first_token.rebuild(
      hpos2x(h1),
      vpos2y(v1),
      @grid_segment_size,
      @grid_segment_size
    )
    @cells[h2][v2] = @second_token.rebuild(
      hpos2x(h2),
      vpos2y(v2),
      @grid_segment_size,
      @grid_segment_size
    )
    @first_token.state = nil
    @first_token.sprite.angle = 0
    @first_token = nil
    @first_token_coords = nil
    @second_token.state = nil
    @second_token.sprite.angle = 0
    @second_token = nil
    @second_token_coords = nil
  end

  def test_swap
    h1 = @first_token_coords[0]
    h2 = @second_token_coords[0]
    v1 = @first_token_coords[1]
    v2 = @second_token_coords[1]

    @cells[h1][v1] = @second_token.rebuild(
      hpos2x(h1),
      vpos2y(v1),
      @grid_segment_size,
      @grid_segment_size
    )
    @cells[h2][v2] = @first_token.rebuild(
      hpos2x(h2),
      vpos2y(v2),
      @grid_segment_size,
      @grid_segment_size
    )
    set_state(:clearing_matches)
    if !clearing_matches then
      undo_swap
      set_state(:seeking_first_token)
      clash_sound
    else
      @first_token.state = nil
      @first_token.sprite.angle = 0
      @second_token.state = nil
      @second_token.sprite.angle = 0
      @first_token = nil
      @first_token_coords = nil
      @second_token = nil
      @second_token_coords = nil
      set_state(:clear_animation)
      @animation_count = 0
    end
  end

  def inc_total_score inc, msg = ''
    puts "total_score was #{@total_score}, but is now #{@total_score+inc} (#{msg})" if @debug
    @total_score += inc
  end

  def clearing_matches
    match_found = false
    @score_for_last_cycle = @score_for_this_cycle
    @score_for_this_cycle = 0
    # one direction, I think vertical despite how I have hpos/vpos here
    @cells.each_with_index do |row, hpos|
      prev_last_seen = nil
      last_seen = nil
      last_seen_counter = 1
      row.each_with_index do |cell, vpos|
        next if @cells[hpos][vpos].nil?
        if !last_seen.nil? && @cells[hpos][vpos].type == last_seen.type then
          last_seen_counter += 1
          if last_seen_counter >= 3 then
            prev_last_seen.match_state = true
            last_seen.match_state = true
            @cells[hpos][vpos].match_state = true
            match_found = true
            @score_for_this_cycle += last_seen_counter * (@score_multiplier + 1)
            match_sound @cells[hpos][vpos].type
          end
          prev_last_seen = last_seen
        else
          last_seen_counter = 1
          prev_last_seen = nil
        end
        last_seen = @cells[hpos][vpos]
      end
    end
    # the other direction, relying on the grid being a square, via a swap of hpos,vpos with vpos,hpos
    @cells.each_with_index do |row, hpos|
      prev_last_seen = nil
      last_seen = nil
      last_seen_counter = 1
      row.each_with_index do |cell, vpos|
        next if @cells[vpos][hpos].nil?
        if !last_seen.nil? && @cells[vpos][hpos].type == last_seen.type then
          last_seen_counter += 1
          if last_seen_counter >= 3 then
            prev_last_seen.match_state = true
            last_seen.match_state = true
            @cells[vpos][hpos].match_state = true
            match_found = true
            @score_for_this_cycle += last_seen_counter * (@score_multiplier + 1)
            match_sound @cells[vpos][hpos].type
          end
          prev_last_seen = last_seen
        else
          last_seen_counter = 1
          prev_last_seen = nil
        end
        last_seen = @cells[vpos][hpos]
      end
    end
    #set_state(:temp)
    puts "match_found = #{match_found}" if @debug
    inc_total_score(@score_for_this_cycle,'clearing_matches') if match_found
    match_found
  end

  def tick
    handle_mouse if [:seeking_first_token,:seeking_second_token].include? @state
    handle_keyboard if [:seeking_first_token,:seeking_second_token].include? @state
    render_grid
    render_cells
    render_text
    case @state
    when :testing_swap then test_swap
    when :remove_matches then remove_matches
    when :drop_pieces then drop_pieces
    end
  end
end

def tick args
  args.state.game ||= Game.new args
  args.state.game.tick
end
