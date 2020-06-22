$gtk.reset

class PhaseFX
  #############################################################################
  # setup
  
  def initialize args
    @args = args
    @args.state.players = [{
      :intend_x => 0,
      :intend_y => 0,
      :speed_x => 10,
      :speed_y => 10,
      :collision_x => false,
      :collision_y => false,
      :x => @args.grid.rect[2].half,
      :y => @args.grid.rect[3].half,
      :w => 128,
      :h => 101,
      :rotation => 0,
      :rotated_on => 0,
      :sprite_idx => 1
    }]
    @args.state.sprite_path = {
      :monsters => "sprites/DungeonAssetPack/SpriteFolder/Monsters/"
    }
    @args.state.keyup_delay = 10
    render_background
    play_bg_music
  end # of initialize

  def serialize
    {
      :player => @args.state.players[0]
    }
  end # of serialize

  def inspect
    serialize.to_s
  end # of inspect

  def to_s
    serialize.to_s
  end # of to_s

  #############################################################################
  # collect input

  def input

    ###########################################################################
    # mouse

    if @args.inputs.mouse.button_right then rotate_right end
    if @args.inputs.mouse.button_left then rotate_left end

    if @args.inputs.mouse.click
      #@args.state.x = @args.inputs.mouse.click.point.x
      #@args.state.y = @args.inputs.mouse.click.point.y
    end

    ###########################################################################
    # arrow keys

    if @args.inputs.keyboard.key_held.right then rotate_right end
    if @args.inputs.keyboard.key_held.left then rotate_left end
    if @args.inputs.keyboard.key_down.up then @args.state.players[0][:sprite_idx] += 1 end
    if @args.inputs.keyboard.key_down.down then @args.state.players[0][:sprite_idx] -= 1 end
    if @args.inputs.keyboard.key_down.pagedown then @args.state.players[0][:sprite_idx] = 1 end
    if @args.inputs.keyboard.key_down.pageup then @args.state.players[0][:rotation] = 0 end
    if @args.state.players[0][:sprite_idx] < 1 then @args.state.players[0][:sprite_idx] = 1 end
    if @args.state.players[0][:sprite_idx] > 15 then @args.state.players[0][:sprite_idx] = 15 end

    ###########################################################################
    # WASD

    key_shift = false
    key_x_axis = false
    key_y_axis = false
    key_w = false
    key_a = false
    key_s = false
    key_d = false
    if @args.inputs.keyboard.key_down.truthy_keys.length > 0 then
      @args.inputs.keyboard.key_down.truthy_keys.each do |truth|
        #if truth == :shift then key_shift = true ; @args.state.players[0][:keypress_on] = @args.state.tick_count ; end
        if truth == :w then key_w = true ; key_y_axis = true ; @args.state.players[0][:keypress_on] = @args.state.tick_count ; end
        if truth == :a then key_a = true ; key_x_axis = true ; @args.state.players[0][:keypress_on] = @args.state.tick_count ; end
        if truth == :s then key_s = true ; key_y_axis = true ; @args.state.players[0][:keypress_on] = @args.state.tick_count ; end
        if truth == :d then key_d = true ; key_x_axis = true ; @args.state.players[0][:keypress_on] = @args.state.tick_count ; end
      end
    end
    if @args.inputs.keyboard.key_up.truthy_keys.length > 0 then
      @args.inputs.keyboard.key_up.truthy_keys.each do |truth|
        #if truth == :shift then key_shift = false end
        if truth == :w then key_w = false end
        if truth == :a then key_a = false end
        if truth == :s then key_s = false end
        if truth == :d then key_d = false end
      end
    end

    if key_w then
      intend_move_up key_shift ? 2 : 1
    elsif !key_y_axis && !@args.inputs.keyboard.key_held.w && !@args.inputs.keyboard.key_held.s && @args.state.tick_count > @args.state.players[0][:keypress_on] + @args.state.keyup_delay then
      intend_move_up 0
    end
    if key_a then
      intend_move_left key_shift ? 2 : 1
    elsif !key_x_axis && !@args.inputs.keyboard.key_held.a && !@args.inputs.keyboard.key_held.d && @args.state.tick_count > @args.state.players[0][:keypress_on] + @args.state.keyup_delay then
      intend_move_left 0
    end
    if key_s then
      intend_move_down key_shift ? 2 : 1
    elsif !key_y_axis && !@args.inputs.keyboard.key_held.w && !@args.inputs.keyboard.key_held.s && @args.state.tick_count > @args.state.players[0][:keypress_on] + @args.state.keyup_delay then
      intend_move_down 0
    end
    if key_d then
      intend_move_right key_shift ? 2 : 1
    elsif !key_x_axis && !@args.inputs.keyboard.key_held.a && !@args.inputs.keyboard.key_held.d && @args.state.tick_count > @args.state.players[0][:keypress_on] + @args.state.keyup_delay then
      intend_move_right 0
    end

    ###########################################################################
    # misc


  end # of input

  #############################################################################
  # handle the game logic

  def intend_move_left relative_speed
    puts "intend_move_left #{relative_speed}" if relative_speed != 0
    @args.state.players[0][:intend_x] = -relative_speed;
  end

  def intend_move_right relative_speed
    puts "intend_move_right #{relative_speed}" if relative_speed != 0
    @args.state.players[0][:intend_x] = relative_speed;
  end

  def intend_move_up relative_speed
    @args.state.players[0][:intend_y] = relative_speed;
  end

  def intend_move_down relative_speed
    @args.state.players[0][:intend_y] = -relative_speed;
  end

  def player_collision?
    @args.state.players[0][:proposed_rect] = [ @args.state.players[0].x, @args.state.players[0].y, @args.state.players[0].w, @args.state.players[0].h ];
    #puts "proposed_rect = #{@args.state.players[0][:proposed_rect]}"
    return false;
  end

  def move_left relative_speed
    #puts "move_left #{relative_speed}"
    @args.state.players[0].x -= @args.state.players[0][:speed_x] * relative_speed.abs
    if @args.state.players[0].x < @args.grid.rect[0] - @args.state.players[0].w.half then
      @args.state.players[0].x = @args.grid.rect[2] + @args.state.players[0].w.half
    end
    @args.state.players[0][:collision_x] = player_collision?
  end

  def move_right relative_speed
    #puts "move_right #{relative_speed}"
    @args.state.players[0].x += @args.state.players[0][:speed_x] * relative_speed.abs
    if @args.state.players[0].x > @args.grid.rect[2] + @args.state.players[0].w.half then
      @args.state.players[0].x = @args.grid.rect[0] - @args.state.players[0].w.half
    end
    @args.state.players[0][:collision_x] = player_collision?
  end

  def move_up relative_speed
    @args.state.players[0].y += @args.state.players[0][:speed_y] * relative_speed.abs
    @args.state.players[0][:collision_y] = player_collision?
  end

  def move_down relative_speed
    @args.state.players[0].y -= @args.state.players[0][:speed_y] * relative_speed.abs
    @args.state.players[0][:collision_y] = player_collision? || @args.state.players[0].y < 0;
  end

  def rotate_left
    if @args.state.players[0][:rotation] < 45 then @args.state.players[0][:rotation] += 2 else @args.state.players[0][:rotation] += 10 end
    if @args.state.players[0][:rotation] > 270 then @args.state.players[0][:rotation] -= 360 end
    @args.state.players[0][:rotated_on] = @args.state.tick_count
  end

  def rotate_right
    if @args.state.players[0][:rotation] > -45 then @args.state.players[0][:rotation] -= 2 else @args.state.players[0][:rotation] -= 10 end
    if @args.state.players[0][:rotation] < -270 then @args.state.players[0][:rotation] += 360 end
    @args.state.players[0][:rotated_on] = @args.state.tick_count
  end

  def intents
    saved_x = @args.state.players[0].x
    saved_y = @args.state.players[0].y
    if @args.state.players[0][:intend_x] > 0 then move_right @args.state.players[0][:intend_x] end
    if @args.state.players[0][:intend_x] < 0 then move_left @args.state.players[0][:intend_x] end
    if @args.state.players[0][:intend_y] > 0 then move_up @args.state.players[0][:intend_y] end
    if @args.state.players[0][:intend_y] < 0 then move_down @args.state.players[0][:intend_y] end
    #@args.state.players[0][:intend_x] = 0
    #@args.state.players[0][:intend_y] = 0
    if @args.state.players[0][:collision_x] then
      @args.state.players[0].x = saved_x
    end
    if @args.state.players[0][:collision_y] then
      @args.state.players[0].y = saved_y
    end
  end

  def iterate

    # slowly level out any rotation
    if @args.state.players[0][:rotation] > 0 and @args.state.tick_count > @args.state.players[0][:rotated_on] + 10 then @args.state.players[0][:rotation] -= 0.5 end
    if @args.state.players[0][:rotation] < 0 and @args.state.tick_count > @args.state.players[0][:rotated_on] + 10 then @args.state.players[0][:rotation] += 0.5 end

    # handle intended movement
    intents

  end # of iterate

  #############################################################################
  # audio stuff

  def play_bg_music
    @args.outputs.sounds << "music/A Long Way.ogg"
  end
 
  #############################################################################
  # draw stuff
 
  def render
    # render_background -> done once in init
    render_something
  end # of render
  
  def render_background
    puts "inside render_background"
    # for the static_ variants, you only want to push into these once, unless
    # you're going to manually clear with each tick
    #@args.outputs.static_solids.clear;
    @args.outputs.static_solids << {
      x:  @args.grid.rect[0],
      y:  @args.grid.rect[1],
      w:  @args.grid.rect[2],
      h:  @args.grid.rect[3],
      r:    0,
      g:  255,
      b:    0,
      a:  64
    }.solid
  end # of render_background

  def render_something
    path = "#{@args.state.sprite_path[:monsters]}monster#{@args.state.players[0][:sprite_idx]}.png"
    face_left = false
    if @args.inputs.keyboard.directional_vector then
      face_left = @args.inputs.keyboard.directional_vector[0] < 0
    elsif
      face_left = @args.inputs.mouse.x < @args.state.players[0].x
    end
    @args.outputs.primitives << {
      x: @args.state.players[0].x-64,
      y: @args.state.players[0].y-50,
      w: 128,
      h: 101,
      path: path,
      angle: @args.state.players[0][:rotation],
      a: 255,
      r: 255,
      g: 255,
      b: 255,
      tile_x:  0,
      tile_y:  0,
      tile_w: -1,
      tile_h: -1,
      flip_vertically: false,
      flip_horizontally: face_left,
      angle_anchor_x: 0.5,
      angle_anchor_y: 0.5
    }.sprite
  end # of render_something

  #############################################################################
  # game loop

  def tick
    render
    input
    iterate
  end # of tick

end # of class PhaseFX

###############################################################################
# main

def tick args
  args.state.game ||= PhaseFX.new args
  args.state.game.tick
  #puts "60 ticks..." if args.state.tick_count % 60 == 0
end # of tick
