module Input

  #############################################################################
  # collect input

  def input actor, idx

    ###########################################################################
    # mouse

    if @mouse.button_right then rotate_right actor end
    if @mouse.button_left then rotate_left actor end

    if @mouse.click
      #@args.state.x = @mouse.click.point.x
      #@args.state.y = @mouse.click.point.y
    end

    ###########################################################################
    # arrow keys

    if @kb.key_held.right then rotate_right actor end
    if @kb.key_held.left then rotate_left actor end
    if @kb.key_down.up then actor[:sprite_idx] += 1 end
    if @kb.key_down.down then actor[:sprite_idx] -= 1 end
    if @kb.key_down.pagedown then actor[:sprite_idx] = 1 end
    if @kb.key_down.pageup then actor[:rotation] = 0 end
    if actor[:sprite_idx] < 1 then actor[:sprite_idx] = 1 end
    if actor[:sprite_idx] > 15 then actor[:sprite_idx] = 15 end

    ###########################################################################
    # WASD

    key_shift = false
    key_x_axis = false
    key_y_axis = false
    key_w = false
    key_a = false
    key_s = false
    key_d = false
    if @kb.key_down.truthy_keys.length > 0 then
      @kb.key_down.truthy_keys.each do |truth|
        #if truth == :shift then key_shift = true ; actor[:keypress_on] = @args.state.tick_count ; end
        if truth == :w then key_w = true ; key_y_axis = true ; actor[:keypress_on] = @args.state.tick_count ; end
        if truth == :a then key_a = true ; key_x_axis = true ; actor[:keypress_on] = @args.state.tick_count ; end
        if truth == :s then key_s = true ; key_y_axis = true ; actor[:keypress_on] = @args.state.tick_count ; end
        if truth == :d then key_d = true ; key_x_axis = true ; actor[:keypress_on] = @args.state.tick_count ; end
      end
    end
    if @kb.key_up.truthy_keys.length > 0 then
      @kb.key_up.truthy_keys.each do |truth|
        #if truth == :shift then key_shift = false end
        if truth == :w then key_w = false end
        if truth == :a then key_a = false end
        if truth == :s then key_s = false end
        if truth == :d then key_d = false end
      end
    end

    if key_w then
      intend_move_up actor, key_shift ? 2 : 1
    elsif !key_y_axis && !@kb.key_held.w && !@kb.key_held.s && @args.state.tick_count > actor[:keypress_on] + @args.state.keyup_delay then
      intend_move_up actor, 0
    end
    if key_a then
      intend_move_left actor, key_shift ? 2 : 1
    elsif !key_x_axis && !@kb.key_held.a && !@kb.key_held.d && @args.state.tick_count > actor[:keypress_on] + @args.state.keyup_delay then
      intend_move_left actor, 0
    end
    if key_s then
      intend_move_down actor, key_shift ? 2 : 1
    elsif !key_y_axis && !@kb.key_held.w && !@kb.key_held.s && @args.state.tick_count > actor[:keypress_on] + @args.state.keyup_delay then
      intend_move_down actor, 0
    end
    if key_d then
      intend_move_right actor, key_shift ? 2 : 1
    elsif !key_x_axis && !@kb.key_held.a && !@kb.key_held.d && @args.state.tick_count > actor[:keypress_on] + @args.state.keyup_delay then
      intend_move_right actor, 0
    end

    ###########################################################################
    # misc

    if @kb.key_down.r then
      @args.state[:reset_desired?] = true
    end
    if @kb.key_down.g then
      @args.state[:gravity?] = ! @args.state[:gravity?]
    end
    if @kb.key_down.b then
      @args.state[:wireframe?] = ! @args.state[:wireframe?]
    end

  end # of input
end # of Input
