$gtk.reset
$gtk.set_window_title "PhaseFX"

LEVEL_001 = 'app/level_001.rb'
require LEVEL_001

class PhaseFX
  #############################################################################
  # setup
  
  def initialize args
    @args = args
    @args.state.actors = [{
      :intend_x_dir => 0,
      :intend_y_dir => 0,
      :speed_x => 10,
      :speed_y => 10,
      :collision_x => false,
      :collision_y => false,
      :x => @args.grid.rect[2].half,
      :y => @args.grid.rect[3].half,
      :proposed_x => @args.grid.rect[2].half,
      :proposed_y => @args.grid.rect[3].half,
      :w => 128,
      :h => 101,
      :rotation => 0,
      :rotated_on => 0,
      :gravity? => true,
      :sprite_idx => 1,
      :sprite_type => :monster
    }].concat(level_001)
    @args.state.sprite_path = {
      :monster => "sprites/DungeonAssetPack/SpriteFolder/Monsters/monster"
    }
    @args.state.keyup_delay = 10
    render_background
    play_bg_music
  end # of initialize

  def serialize
    {
      :actors => @args.state.actors
    }
  end # of serialize

  def inspect
    serialize.to_s
  end # of inspect

  def to_s
    serialize.to_s
  end # of to_s

  def state
    puts "state called"
  end

  #############################################################################
  # collect input

  def input

    player1 = @args.state.actors[0]
    mouse = @args.inputs.mouse
    keyboard = @args.inputs.keyboard

    ###########################################################################
    # mouse

    if mouse.button_right then rotate_right player1 end
    if mouse.button_left then rotate_left player1 end

    if mouse.click
      #@args.state.x = mouse.click.point.x
      #@args.state.y = mouse.click.point.y
    end

    ###########################################################################
    # arrow keys

    if keyboard.key_held.right then rotate_right player1 end
    if keyboard.key_held.left then rotate_left player1 end
    if keyboard.key_down.up then player1[:sprite_idx] += 1 end
    if keyboard.key_down.down then player1[:sprite_idx] -= 1 end
    if keyboard.key_down.pagedown then player1[:sprite_idx] = 1 end
    if keyboard.key_down.pageup then player1[:rotation] = 0 end
    if player1[:sprite_idx] < 1 then player1[:sprite_idx] = 1 end
    if player1[:sprite_idx] > 15 then player1[:sprite_idx] = 15 end

    ###########################################################################
    # WASD

    key_shift = false
    key_x_axis = false
    key_y_axis = false
    key_w = false
    key_a = false
    key_s = false
    key_d = false
    if keyboard.key_down.truthy_keys.length > 0 then
      keyboard.key_down.truthy_keys.each do |truth|
        #if truth == :shift then key_shift = true ; player1[:keypress_on] = @args.state.tick_count ; end
        if truth == :w then key_w = true ; key_y_axis = true ; player1[:keypress_on] = @args.state.tick_count ; end
        if truth == :a then key_a = true ; key_x_axis = true ; player1[:keypress_on] = @args.state.tick_count ; end
        if truth == :s then key_s = true ; key_y_axis = true ; player1[:keypress_on] = @args.state.tick_count ; end
        if truth == :d then key_d = true ; key_x_axis = true ; player1[:keypress_on] = @args.state.tick_count ; end
      end
    end
    if keyboard.key_up.truthy_keys.length > 0 then
      keyboard.key_up.truthy_keys.each do |truth|
        #if truth == :shift then key_shift = false end
        if truth == :w then key_w = false end
        if truth == :a then key_a = false end
        if truth == :s then key_s = false end
        if truth == :d then key_d = false end
      end
    end

    if key_w then
      intend_move_up player1, key_shift ? 2 : 1
    elsif !key_y_axis && !keyboard.key_held.w && !keyboard.key_held.s && @args.state.tick_count > player1[:keypress_on] + @args.state.keyup_delay then
      intend_move_up player1, 0
    end
    if key_a then
      intend_move_left player1, key_shift ? 2 : 1
    elsif !key_x_axis && !keyboard.key_held.a && !keyboard.key_held.d && @args.state.tick_count > player1[:keypress_on] + @args.state.keyup_delay then
      intend_move_left player1, 0
    end
    if key_s then
      intend_move_down player1, key_shift ? 2 : 1
    elsif !key_y_axis && !keyboard.key_held.w && !keyboard.key_held.s && @args.state.tick_count > player1[:keypress_on] + @args.state.keyup_delay then
      intend_move_down player1, 0
    end
    if key_d then
      intend_move_right player1, key_shift ? 2 : 1
    elsif !key_x_axis && !keyboard.key_held.a && !keyboard.key_held.d && @args.state.tick_count > player1[:keypress_on] + @args.state.keyup_delay then
      intend_move_right player1, 0
    end

    ###########################################################################
    # misc


  end # of input

  #############################################################################
  # handle the game logic

  def intend_move_left actor, relative_speed
    #puts "intend_move_left #{relative_speed}" if relative_speed != 0
    actor[:intend_x_dir] = -relative_speed;
  end

  def intend_move_right actor, relative_speed
    #puts "intend_move_right #{relative_speed}" if relative_speed != 0
    actor[:intend_x_dir] = relative_speed;
  end

  def intend_move_up actor, relative_speed
    actor[:intend_y_dir] = relative_speed;
  end

  def intend_move_down actor, relative_speed
    actor[:intend_y_dir] = -relative_speed;
  end

  def actor_collision? idx

    actor = @args.state.actors[idx]
    other_actors = @args.state.actors.select.with_index { |v,i| i != idx }

    collision = other_actors.any? { |oa|
      [oa[:proposed_x], oa[:proposed_y], oa.w, oa.h].intersect_rect? [actor[:proposed_x], actor[:proposed_y], actor.w, actor.h] }

    return collision
  end

  def move_left actor, idx, relative_speed
    #puts "move_left #{relative_speed}"
    actor[:proposed_x] -= actor[:speed_x] * relative_speed.abs
    if actor[:proposed_x] < @args.grid.rect[0] - actor.w.half then
      actor[:proposed_x] = @args.grid.rect[2] + actor.w.half
    end
    actor[:collision_x] = actor_collision? idx
  end

  def move_right actor, idx, relative_speed
    #puts "move_right #{relative_speed}"
    actor[:proposed_x] += actor[:speed_x] * relative_speed.abs
    if actor[:proposed_x] > @args.grid.rect[2] + actor.w.half then
      actor[:proposed_x] = @args.grid.rect[0] - actor.w.half
    end
    actor[:collision_x] = actor_collision? idx
  end

  def move_up actor, idx, relative_speed
    actor[:proposed_y] += actor[:speed_y] * relative_speed.abs
    actor[:collision_y] = actor_collision? idx
  end

  def move_down actor, idx, relative_speed
    actor[:proposed_y] -= actor[:speed_y] * relative_speed.abs
    actor[:collision_y] = actor_collision? idx # || actor[:proposed_y] < 0;
  end

  def rotate_left actor
    if actor[:rotation] < 45 then actor[:rotation] += 2 else actor[:rotation] += 10 end
    #actor[:rotation] += actor[:rotation]/10 + 1
    if actor[:rotation] > 270 then actor[:rotation] -= 360 end
    actor[:rotated_on] = @args.state.tick_count
  end

  def rotate_right actor
    if actor[:rotation] > -45 then actor[:rotation] -= 2 else actor[:rotation] -= 10 end
    #actor[:rotation] -= actor[:rotation]/10 + 1
    if actor[:rotation] < -270 then actor[:rotation] += 360 end
    actor[:rotated_on] = @args.state.tick_count
  end

  def gravity
  end

  def proposed_movement
    @args.state.actors.each_with_index do |actor,idx|
      actor[:saved_x] = actor.x
      actor[:saved_y] = actor.y
      if actor[:intend_x_dir] > 0 then move_right actor, idx, actor[:intend_x_dir] end
      if actor[:intend_x_dir] < 0 then move_left actor, idx, actor[:intend_x_dir] end
      if actor[:intend_y_dir] > 0 then move_up actor, idx, actor[:intend_y_dir] end
      if actor[:intend_y_dir] < 0 then move_down actor, idx, actor[:intend_y_dir] end
      #actor[:intend_x_dir] = 0
      #actor[:intend_y_dir] = 0
      if actor[:collision_x] then
        actor[:proposed_x] = actor[:saved_x]
      end
      if actor[:collision_y] then
        actor[:proposed_y] = actor[:saved_y]
      end
    end
  end

  def actual_movement
    @args.state.actors.each do |actor|
      actor.x = actor[:proposed_x]
      actor.y = actor[:proposed_y]
    end
  end

  def iterate

    @args.state.actors.each do |actor|
      # slowly level out any rotation
      if actor[:rotation] > 0 and @args.state.tick_count > actor[:rotated_on] + 10 then actor[:rotation] -= 0.5 end
      if actor[:rotation] < 0 and @args.state.tick_count > actor[:rotated_on] + 10 then actor[:rotation] += 0.5 end
    end

    gravity
    proposed_movement
    actual_movement

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
    @args.state.actors.each_with_index {|actor,idx| render_actor actor,idx }
  end # of render
  
  def render_background
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

  def render_actor actor, idx
    mouse = @args.inputs.mouse
    keyboard = @args.inputs.keyboard
    path = "#{@args.state.sprite_path[actor[:sprite_type]]}#{actor[:sprite_idx]}.png"
    face_left = false
    if idx == 0 then # 0 is the player
      if keyboard.directional_vector then
        face_left = keyboard.directional_vector[0] < 0
      elsif
        face_left = mouse.x < actor.x
      end
    end
    @args.outputs.borders << {
      x: actor.x-actor.w.half,
      y: actor.y-actor.h.half,
      w: actor.w,
      h: actor.h,
      r: 255,
      g: 0,
      b: 0,
      a: 128
    }
    @args.outputs.primitives << {
      x: actor.x-actor.w.half,
      y: actor.y-actor.h.half,
      w: actor.w,
      h: actor.h,
      path: path,
      angle: actor[:rotation],
      a: 255,
      r: 255,
      g: 255,
      b: 128,
      tile_x:  0,
      tile_y:  0,
      tile_w: -1,
      tile_h: -1,
      flip_vertically: false,
      flip_horizontally: face_left,
      angle_anchor_x: 0.5,
      angle_anchor_y: 0.5
    }.sprite
  end # of render_actor

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
