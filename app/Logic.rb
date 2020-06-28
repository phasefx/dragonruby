module Logic

  #############################################################################
  # handle the game logic

  def actor_collision? idx

    actor = @state[:actors][idx]
    other_actors = @state[:actors].select.with_index { |oa,i| i != idx }.select { |oa| oa[:collision_z] == actor[:collision_z] }

    collision = other_actors.any? { |oa|
      [oa[:particle].next_position.x, oa[:particle].next_position.y, oa.w, oa.h].intersect_rect?
      [actor[:particle].next_position.x, actor[:particle].next_position.y, actor.w, actor.h] }

    return collision
  end

  def rotate_left actor
    if actor[:rotation] < 45 then actor[:rotation] += 2 else actor[:rotation] += 10 end
    #actor[:rotation] += actor[:rotation]/10 + 1
    if actor[:rotation] > 270 then actor[:rotation] -= 360 end
    actor[:rotated_on] = @gtk_state.tick_count
  end

  def rotate_right actor
    if actor[:rotation] > -45 then actor[:rotation] -= 2 else actor[:rotation] -= 10 end
    #actor[:rotation] -= actor[:rotation]/10 + 1
    if actor[:rotation] < -270 then actor[:rotation] += 360 end
    actor[:rotated_on] = @gtk_state.tick_count
  end

  def intelligence
    @state[:actors].each_with_index do |actor,idx|
      case actor[:ai_routine]
        when :player then input actor, idx
        when :horizontal 
          # if already moving, more impulses would accelerate. Let's not do that for now
          if actor[:particle].velocity.x.zero? then
            set_impulse actor, actor[:ai_hdir], 0
          end
      end
    end
  end

  def set_impulse actor, x, y
    if !x.nil? && !y.nil? then
      actor[:intended_impulse] = Vector.new x, y
      actor[:intended_on] = @gtk_state.tick_count
    else
      puts "got a nil (#{actor},#{x},#{y})"
    end
  end

  def forces
    @state[:actors].each_with_index do |actor,idx|
      forces_a = []
      if @state[:gravity?] && actor[:gravity?] then
        forces_a << calculate_g_force(actor[:particle])
      end
      if actor[:intended_impulse].x != 0 || actor[:intended_impulse].y !=0
        if actor[:intended_on] > actor[:impulsed_on]
          forces_a << Vector.new(
            actor[:particle].mass * actor[:intended_impulse].x,
            actor[:particle].mass * actor[:intended_impulse].y,
            :impulse
          )
          actor[:impulsed_on] = @gtk_state.tick_count
        end
      end
      calculate_next_vectors actor[:particle], forces_a
    end
  end

  def proposed_movement
    @state[:actors].each_with_index do |actor,idx|
      if actor[:collision_x] then
        actor[:particle].next_position.x = actor[:particle].position.x
        actor[:particle].next_velocity.x = actor[:particle].velocity.x
      end
      if actor[:collision_y] then
        actor[:particle].next_position.y = actor[:particle].position.y
        actor[:particle].next_velocity.y = actor[:particle].velocity.y
      end
      if actor[:particle].next_position.y < 0 then
        # this is cheating; I should be creating an opposing force to gravity for the floor
        # but I think when it comes to collisions I'm going to step away from realistic
        # physics at that point
        actor[:particle].next_position.y = 0
      end
    end
  end

  def actual_movement
    @state[:actors].each do |actor|
      actor[:position] = actor[:next_position]
      actor[:velocity] = actor[:next_velocity]
    end
  end

  def physics

    @state[:actors].each do |actor|
      # slowly level out any rotation
      if actor[:rotation] > 0 and @gtk_state.tick_count > actor[:rotated_on] + 10 then actor[:rotation] -= 0.5 end
      if actor[:rotation] < 0 and @gtk_state.tick_count > actor[:rotated_on] + 10 then actor[:rotation] += 0.5 end
    end

    forces
    proposed_movement
    actual_movement

  end # of physics
end # of Logic
