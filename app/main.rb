$game_debug = false
$game_milestone = :top

class Game

  # for debugging: $gtk.args.state.game.cells, etc
  attr_accessor :cells, :state, :audio, :music_scheme, :sfx_scheme, :reserve_token, :first_token, :note_queue

  INITIAL_GRID_SIZE = 7
  TEXT_HEIGHT = 20
  SHRINK_SPEED = 5
  MOVE_SPEED = 10
  # we have 34 icons; we can use these to mix things up a bit
  FAVORITE_TILES = [1,2,3,4,5,8,9,10]
  UNIQUE_TILES = 7
  TILESHIFT = rand(2)
  # FAVORITE_TILES[rand(UNIQUE_TILES) + TILESHIFT]
  BACH = ['E3','A3','C4','B3','E3','B3','D4']

  def initialize args

    trace! if $game_debug

    $game_milestone = :game_init

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

    @cells = Array.new(@grid_divisions){Array.new(@grid_divisions,nil)}
    @audio_notes = true
    @audio_match = true
    @music_scheme = :sequenced
    @sfx_scheme = :bass
    @note_queue = [ [] ] # for playing notes sequentially; index for outer array is track
    @note_queue_delay = 30 # play on tick_count.mod(delay) == 0

    render_grid # do this now so that we have @grid_segment_size ready for init_cells

    @note_labels = 200.times.map { |i| [
      @grid_offset[0]+(@grid_segment_size*@grid_divisions) + TEXT_HEIGHT*i.mod(10) + 35,
      @uy-TEXT_HEIGHT*i.div(10) - TEXT_HEIGHT*16, "♪"
    ]}

    #init_cells
    render_static
    @animation_count = 0
    set_state(:drop_pieces)
    #if clearing_matches :init then
    #  set_state(:clear_animation)
    #  @animation_count = 0
    #end
  end

  def serialize
    {state:@state,milestone:$game_milestone}
  end

  def inspect
    serialize.to_s
  end

  def to_s
    serialize.to_s
  end

  def set_state s
    puts "stage change: #{@state} to #{s}" if $game_debug
    @state = s
  end

  def queue_note celltype
    puts "queue_note #{celltype} with #{@music_scheme}" if $game_debug
    case @music_scheme
    when :sequenced then bach_invention_13
    end
  end

  def match_sound celltype
    puts "match_sound #{celltype} with #{@music_scheme}" if $game_debug
    case @sfx_scheme
    when :random then random_sound
    when :indexed then indexed_sound FAVORITE_TILES.index(celltype)
    when :bass then @gtk_outputs.sounds << 'media/sfx/bass.wav' if @audio_match
    end
  end

  def indexed_sound idx, queue = false
    puts "playing sound #{idx}" if $game_debug
    a = queue ? @note_queue[0] : @audio_notes && @gtk_outputs.sounds
    case idx
    when 0 then a << 'media/sfx/A3.wav'
    when 1 then a << 'media/sfx/B3.wav'
    when 2 then a << 'media/sfx/C3.wav'
    when 3 then a << 'media/sfx/C4.wav'
    when 4 then a << 'media/sfx/D3.wav'
    when 5 then a << 'media/sfx/E3.wav'
    when 6 then a << 'media/sfx/F3.wav'
    when 7 then a << 'media/sfx/G3.wav'
    else
      # missing note
    end
    puts "note_queue = #{@note_queue}" if $game_debug
  end

  def specific_note note, track = 0, queue = false
    puts "playing note #{note}" if $game_debug
    a = queue ? @note_queue[track] : @audio_notes && @gtk_outputs.sounds
    a << "media/piano/#{note}.wav"
    puts "note_queue = #{@note_queue}" if $game_debug
  end

  def bach_invention_13
    @bach = BACH.clone if @bach.nil? || @bach.empty?
    puts "playing bach" if $game_debug
    #indexed_sound ['A3','B3','C3','C4','D3','E3','F3','G3'].index(@bach.pop), true
    specific_note @bach.pop.downcase, 0, true
  end

  def random_sound
    puts "playing random sound" if $game_debug
    indexed_sound rand(8)
  end

  def clash_sound
    puts "playing all sounds" if $game_debug
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

  def render_reserve
    @reserve_x ||= 90
    @reserve_y ||= 290
    @reserve_w ||= 100
    @reserve_h ||= 100
    #@reserve_token ||= Book.new(
    #  @reserve_x,
    #  @reserve_y,
    #  @reserve_w,
    #  @reserve_h
    #)
    @gtk_outputs.primitives << [
      @reserve_x,
      @reserve_y,
      @reserve_w,
      @reserve_h,
      0, 0, 0, 64
    ].border
    @gtk_outputs.solids << [
      @reserve_x,
      @reserve_y,
      @reserve_w,
      @reserve_h,
      0, 255, 255, 64
    ] if @reserve_selected || @gtk_mouse.point.inside_rect?([@reserve_x,@reserve_y,@reserve_w,@reserve_h])
    @gtk_outputs.sprites << @reserve_token.sprite unless @reserve_token.nil?
  end

  def render_static
    ##                                                     '1234567890123456789012345678' ]
    #@gtk_outputs.static_labels << [@lx,@uy-TEXT_HEIGHT*21,'Press Enter for demo']
    @gtk_outputs.static_sprites << [ @grid_offset[0]+(@grid_segment_size*@grid_divisions)+25, @uy-300, 228, 300, 'media/the_librarian.jpg' ]
  end

  class Sprite
    attr_sprite
    attr_accessor :x, :y, :w, :h, :angle,:type, :target_x, :target_y, :x_moving, :y_moving

    def initialize x, y, w, h, type=nil

      #trace! if $game_debug

      @x = x
      @y = y
      @target_x = x
      @target_y = y
      @w = w
      @h = h
      @x_moving = false
      @y_moving = false
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
      {x:@x,y:@y,w:@w,h:@h,x_moving:@x_moving,y_moving:@y_moving,target_x:@target_x,target_y:@target_y,angle:@angle,type:@type,path:@path}
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end
  end

  class Book
    attr_accessor :type, :state, :match_state, :sprite

    def initialize x, y, w, h, type=nil

      #trace! if $game_debug

      @type = type.nil? ? FAVORITE_TILES[rand(UNIQUE_TILES) + TILESHIFT] : type
      puts "bad tile selection #{@type}" if ! FAVORITE_TILES.include? @type
      #@match_state = false
      #@state = nil
      @sprite = Sprite.new(x,y,w,h,@type)
    end

    # need to look into .dup and .clone, but for now...
    def copy
      Book.new(@sprite.x,@sprite.y,@sprite.w,@sprite.h,@type)
    end

    def rebuild x, y, w, h
      @sprite.rebuild x, y, w, h
      self
    end

    def move_to x, y
      @sprite.target_x = x
      @sprite.target_y = y
      @sprite.y_moving = @sprite.target_y <=> @sprite.y
      @sprite.x_moving = @sprite.target_x <=> @sprite.x
      @sprite.y_moving = false if @sprite.y_moving == 0
      @sprite.x_moving = false if @sprite.x_moving == 0
      puts "x: #{@sprite.x_moving}, #{@sprite.x} to #{@sprite.target_x}  y: #{@sprite.y_moving}, #{@sprite.y} to #{@sprite.target_y}" if $game_debug
      self
    end

    def serialize
      {state:@state,match_state:@match_state,type:@type,sprite:@sprite}
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
        cell = @cells[hpos][vpos]
        cell.move_to(
          hpos2x(hpos),
          vpos2y(vpos)
        )
        if (cell.sprite.x - cell.sprite.target_x).abs > @grid_segment_size*2 then
          cell.sprite.x = cell.sprite.target_x + @grid_segment_size * (cell.sprite.x <=> cell.sprite.target_x)
        end
        if (cell.sprite.y - cell.sprite.target_y).abs > @grid_segment_size*2 then
          cell.sprite.y = cell.sprite.target_y + @grid_segment_size * (cell.sprite.y <=> cell.sprite.target_y)
        end
      end
    end
    set_state(:grid_shifting)
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
    puts "inside test_for_nils" if $game_debug
    found = false
    @cells.each_with_index do |row, hpos|
      row.each_with_index do |cell, vpos|
        found = true if @cells[hpos][vpos].nil?
      end
    end
    puts "found nills = #{found}" if $game_debug
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
              @cells[hpos][vpos] = @cells[hpos][wrap(vpos+1)].nil? ? nil : @cells[hpos][wrap(vpos+1)].move_to(
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
              ).move_to(
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
    pieces_moving = false
    @cells.each_with_index do |row, hpos|
      row.each_with_index do |cell, vpos|
        cell = @cells[hpos][vpos]
        @gtk_outputs.labels << [ hpos2x(hpos), vpos2y(vpos) + TEXT_HEIGHT, "#{hpos}, #{vpos}" ] if $game_debug
        @gtk_outputs.labels << [ hpos2x(hpos), vpos2y(vpos) + @grid_segment_size, "#{cell.nil? ? 'nil' : cell.type}" ] if $game_debug
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
        if cell.sprite.y_moving && ([:pieces_dropping,:grid_shifting].include? @state) then
          cell.sprite.y += MOVE_SPEED * cell.sprite.y_moving
          if cell.sprite.y_moving < 0 ? cell.sprite.y <= cell.sprite.target_y : cell.sprite.y >= cell.sprite.target_y then
            cell.sprite.y = cell.sprite.target_y # snap to grid
            #cell.sprite.target_y = nil
            #puts "#{hpos},#{vpos} no longer y-moving #{cell.sprite.y_moving} (#{cell.sprite.y} vs #{cell.sprite.target_y})"
            cell.sprite.y_moving = false
          else
            pieces_moving = true
            #puts "#{hpos},#{vpos} still y-moving #{cell.sprite.y_moving} (#{cell.sprite.y} vs #{cell.sprite.target_y})"
          end
        end
        if cell.sprite.x_moving && ([:grid_shifting].include? @state) then
          cell.sprite.x += MOVE_SPEED * cell.sprite.x_moving
          if cell.sprite.x_moving < 0 ? cell.sprite.x <= cell.sprite.target_x : cell.sprite.x >= cell.sprite.target_x then
            cell.sprite.x = cell.sprite.target_x # snap to grid
            #cell.sprite.target_x = nil
            #puts "#{hpos},#{vpos} no longer x-moving #{cell.sprite.x_moving} (#{cell.sprite.x} vs #{cell.sprite.target_x})"
            cell.sprite.x_moving = false
          else
            pieces_moving = true
            #puts "#{hpos},#{vpos} still x-moving #{cell.sprite.x_moving} (#{cell.sprite.x} vs #{cell.sprite.target_x})"
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
    if !pieces_moving && ([:pieces_dropping,:grid_shifting].include? @state) then
      if clearing_matches :render_cells then
        old_combo = @current_combo
        @combo_count += 1
        if @combo_count == 1 then
          @current_combo += @score_for_last_cycle
        end
        @current_combo += @score_for_this_cycle
        puts "combo count = #{@combo_count} current_combo was #{old_combo}, but is now #{@current_combo}" if $game_debug
        set_state(:clear_animation)
        @animation_count = 0
      else
        puts "end of combo, current_combo = #{@current_combo}" if $game_debug
        @last_combo = @current_combo
        @highest_combo = @current_combo if @current_combo > @highest_combo
        @current_combo = 0
        @combo_count = 0
        set_state(:seeking_first_token)
      end
    elsif pieces_moving && !([:pieces_dropping,:grid_shifting].include? @state) then
      set_state(:pieces_dropping)
    end
  end

  def clear_first_token
    if !@first_token.nil? then
      @first_token.sprite.angle = 0
      @first_token.state = nil
      @first_token = nil
      @first_token_coords = nil
    end
  end

  def swap_reserve
    h = @first_token_coords[0]
    v = @first_token_coords[1]
    @cells[h][v] = @reserve_token.nil? ? nil : @reserve_token.rebuild(
      @reserve_token.sprite.x,
      @reserve_token.sprite.y,
      @grid_segment_size,
      @grid_segment_size
    ).move_to(
      hpos2x(h),
      vpos2y(v)
    )
    @reserve_token = @first_token.copy.rebuild(
      @reserve_x,
      @reserve_y,
      @reserve_w,
      @reserve_h
    )
    clear_first_token
    if @cells[h][v].nil? then
      set_state(:drop_pieces)
    else
      set_state(:grid_shifting)
    end
  end

  def handle_cell_click hpos, vpos, entry_state
    # return true for valid cells
    puts "inside handle_cell_click #{hpos}, #{vpos} during #{@state}" if $game_debug
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
          clear_first_token
          return true
        # make sure the proposed second token is adjacent to the first (diagonals do not count)
        elsif (((@first_token_coords[0] - hpos).abs < 2 && (@first_token_coords[1] - vpos).abs == 0) || ((@first_token_coords[0] - hpos).abs == 0 && (@first_token_coords[1] - vpos).abs < 2) ) && @cells[hpos][vpos].state.nil? then
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
      elsif @state == :reserve_selected
        if @cells[hpos][vpos].state.nil? then
          clear_first_token
          @cells[hpos][vpos].state = :first_token
          @cells[hpos][vpos].sprite.angle = -45
          @first_token = @cells[hpos][vpos]
          @first_token_coords = [ hpos, vpos ]
          swap_reserve
          return true
        else
          # reserved for future use; cells that can't be selected?
          return false
        end
      else
        # game is in a state where selection should be disabled
        return false
      end
    elsif @gtk_mouse.point.inside_rect? [@reserve_x,@reserve_y,@reserve_w,@reserve_h]
      if @state == :seeking_first_token then
        if @reserve_token.nil? then # don't allow an empty reserve to be selected as a first selection
          return false
        else
          set_state(:reserve_selected)
        end
      elsif @state == :seeking_second_token
        swap_reserve
      elsif @state == :reserve_selected
        set_state(:seeking_first_token)
      end
      return true
    end # if hpos > -1 && hpos < @grid_divisions && vpos > -1 && vpos < @grid_divisions then
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
      puts "inside @gtk_mouse.down; hpos = #{hpos} vpos = #{vpos} hpos2x = #{hpos2x(hpos)} vpos2y = #{vpos2y(vpos)} mouse.x = #{@gtk_mouse.x} mouse.y = #{@gtk_mouse.y}" if $game_debug
      if @gtk_mouse.button_middle then
        set_state(:reserve_selected)
        handle_cell_click hpos, vpos, :middle_click
      else
        @mouse_down = true
        @mouse_down_at = @gtk_args.tick_count
        @mouse_down_initial_hpos = hpos
        @mouse_down_initial_vpos = vpos
        @mouse_down_initial_x = @gtk_mouse.x
        @mouse_down_initial_y = @gtk_mouse.y
        handle_cell_click hpos, vpos, :mouse_down
      end
    elsif @gtk_mouse.up then
      puts "inside @gtk_mouse.up" if $game_debug
      if hpos != @mouse_down_initial_hpos || vpos != @mouse_down_initial_vpos then
        handle_cell_click(hpos, vpos, :mouse_up)
      end
      @mouse_down = false
      @mouse_down_at = nil
      @mouse_down_initial_hpos = nil
      @mouse_down_initial_vpos = nil
      @mouse_down_initial_x = nil
      @mouse_down_initial_y = nil
    elsif @gtk_mouse.wheel && @gtk_mouse.wheel.x < 0 then
      @cells = @cells.rotate(-1)
      rebuild_cells
    elsif @gtk_mouse.wheel && @gtk_mouse.wheel.x > 0 then
      @cells = @cells.rotate(1)
      rebuild_cells
    elsif @gtk_mouse.wheel && @gtk_mouse.wheel.y < 0 then
      @cells.each_with_index do |row, hpos|
        @cells[hpos] = @cells[hpos].rotate(-1)
      end
      rebuild_cells
    elsif @gtk_mouse.wheel && @gtk_mouse.wheel.y > 0 then
      @cells.each_with_index do |row, hpos|
        @cells[hpos] = @cells[hpos].rotate(1)
      end
      rebuild_cells
    end
  end

  def handle_keyboard
    @gtk_kb.key_down.truthy_keys.each do |truth|
      if truth == :t then # test
        @gtk_outputs.sounds << 'media/sfx/test.wav'
      end
      if truth == :u then # test
        100.times do queue_note -1 end
      end
      if truth == :i then # debug toggle
        $game_debug = !$game_debug
      end
      if truth == :r then # reset
        clear_first_token
        @cells = Array.new(@grid_divisions){Array.new(@grid_divisions,false)}
        @cells.each_with_index do |row, hpos|
          row.each_with_index do |cell, vpos|
              cells[hpos][vpos] = Book.new(
                hpos2x(rand(@grid_divisions)),
                vpos2y(rand(@grid_divisions)),
                @grid_segment_size,
                @grid_segment_size
              )
              @cells[hpos][vpos].move_to(
                hpos2x(hpos),
                vpos2y(vpos)
              )
          end
        end
        dump if $game_debug
        set_state(:grid_shifting)
        @total_score = 0
      end
      if truth == :close_square_brace then # shrink grid
        clear_first_token
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
        clear_first_token
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
      if truth == :three && !@saved.nil? then # restore
        clear_first_token
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
        clear_first_token
        @saved = Array.new(@grid_divisions){Array.new(@grid_divisions,true)}
        @cells.each_with_index do |row, hpos|
          row.each_with_index do |cell, vpos|
            @saved[hpos][vpos] = @cells[hpos][vpos]
          end
        end
      end
      if truth == :m then
        @audio_match = !@audio_match
      end
      if truth == :n then
        @audio_notes = !@audio_notes
      end
      if truth == :right || truth == :d then
        clear_first_token
        @cells = @cells.rotate(1)
        rebuild_cells
      end
      if truth == :left || truth == :a then
        clear_first_token
        @cells = @cells.rotate(-1)
        rebuild_cells
      end
      if truth == :up || truth == :w then
        clear_first_token
        @cells.each_with_index do |row, hpos|
          @cells[hpos] = @cells[hpos].rotate(1)
        end
        rebuild_cells
      end
      if truth == :down || truth == :s then
        clear_first_token
        @cells.each_with_index do |row, hpos|
          @cells[hpos] = @cells[hpos].rotate(-1)
        end
        rebuild_cells
      end
      if truth == :back_slash then
        clear_first_token
        if !@second_token.nil? then
          @second_token.sprite.angle = 0
          @second_token.state = nil
          @second_token = nil
          @second_token_coords = nil
        end
        set_state(:seeking_first_token)
      end
      if truth == :space then
        hpos = x2hpos @gtk_mouse.x
        vpos = y2vpos @gtk_mouse.y
        set_state(:reserve_selected)
        handle_cell_click hpos, vpos, :spacebar
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
    @gtk_outputs.labels << [ @lx,@uy-TEXT_HEIGHT*6,"R to Reset" ]
    @gtk_outputs.labels << [ @lx,@uy-TEXT_HEIGHT*8,"Arrows/WASD/mouse-wheel" ]
    @gtk_outputs.labels << [ @lx,@uy-TEXT_HEIGHT*9,"to shift grid" ]
    @gtk_outputs.labels << [ @lx,@uy-TEXT_HEIGHT*11,"Space for quick Reserve" ]
    @gtk_outputs.labels << [ @lx,@uy-TEXT_HEIGHT*13,"M to toggle match sound" ]
    @gtk_outputs.labels << [ @lx,@uy-TEXT_HEIGHT*14,"N to toggle music notes" ]
    @gtk_outputs.labels << [ @lx+90,@uy-TEXT_HEIGHT*22,"Reserve" ]
    @gtk_outputs.labels << [ @lx,@ly+TEXT_HEIGHT*1,"FPS #{@gtk_args.gtk.current_framerate.floor}  Tick #{@gtk_args.tick_count}" ]
    ##                                                                                 '1234567890123456789012345678' ]
    @gtk_outputs.labels << [ @grid_offset[0]+(@grid_segment_size*@grid_divisions), @uy,"Mouse: #{@gtk_mouse.x}, #{@gtk_mouse.y}" ] if $game_debug
    @gtk_outputs.labels << @note_labels.take(@note_queue[0].length)
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
    clear_first_token
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
    if !clearing_matches :test_swap then
      undo_swap
      set_state(:seeking_first_token)
      clash_sound
    else
      @second_token.state = nil
      @second_token.sprite.angle = 0
      @second_token = nil
      @second_token_coords = nil
      clear_first_token
      set_state(:clear_animation)
      @animation_count = 0
    end
  end

  def inc_total_score inc, msg = ''
    puts "total_score was #{@total_score}, but is now #{@total_score+inc} (#{msg})" if $game_debug
    @total_score += inc
  end

  def clearing_matches context=''
    puts "inside clearing_matches (#{context})" if $game_debug
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
            (last_seen_counter * 2).times do queue_note @cells[hpos][vpos].type end
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
            match_sound @cells[hpos][vpos].type
            (last_seen_counter * 2).times do queue_note @cells[hpos][vpos].type end
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
    puts "match_found = #{match_found}" if $game_debug
    inc_total_score(@score_for_this_cycle,'clearing_matches') if match_found
    match_found
  end

  def tick
    handle_mouse if [:seeking_first_token,:seeking_second_token,:reserve_selected].include? @state
    handle_keyboard if [:seeking_first_token,:seeking_second_token,:reserve_selected].include? @state
    render_grid
    render_reserve
    render_cells
    render_text
    case @state
    when :testing_swap then test_swap
    when :remove_matches then remove_matches
    when :drop_pieces then drop_pieces
    end
    if @gtk_args.tick_count.mod(@note_queue_delay) == 0 then
      @note_queue.each_with_index do |note,idx|
        sound = @note_queue[idx].shift if ! @note_queue[idx].empty?
        @gtk_outputs.sounds << sound if @audio_notes && !sound.nil?
      end
    end
  end
end

def dump
  $gtk.args.state.game.cells.each_with_index do |row, hpos|
    row.each_with_index do |cell, vpos|
      c = $gtk.args.state.game.cells[hpos][vpos]
        puts "pos = #{hpos}, #{vpos} x,y = #{c.sprite.x},#{c.sprite.y} tx,ty = #{c.sprite.target_x},#{c.sprite.target_y} mx,my = #{c.sprite.x_moving}, #{c.sprite.y_moving}" #if $game_debug
    end
  end
  return nil
end

def tick args
  args.state.game ||= Game.new args
  args.state.game.tick
end
