module Logic

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
    other_actors = @args.state.actors.select.with_index { |oa,i| i != idx }.select { |oa| oa[:collision_z] == actor[:collision_z] }

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
    if (!actor[:collision_y]) then
      if actor[:proposed_y] < 0 then
        actor[:collision_y] = true
      end
    end
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

  def intelligence
    @args.state.actors.each_with_index do |actor,idx|
      case actor[:ai_routine]
        when :player then input actor, idx
        when :horizontal then intend_move_left actor, actor[:ai_hdir]
      end
    end
  end

  def forces
    @args.state.actors.each_with_index do |actor,idx|
      if @args.state[:gravity?] && actor[:gravity?] then
        move_down actor, idx, -1
      end
    end
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

  def physics

    @args.state.actors.each do |actor|
      # slowly level out any rotation
      if actor[:rotation] > 0 and @args.state.tick_count > actor[:rotated_on] + 10 then actor[:rotation] -= 0.5 end
      if actor[:rotation] < 0 and @args.state.tick_count > actor[:rotated_on] + 10 then actor[:rotation] += 0.5 end
    end

    forces
    proposed_movement
    actual_movement

  end # of physics
end # of Logic
