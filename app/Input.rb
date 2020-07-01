module Input

  #############################################################################
  # collect input

  def input actor, idx

    ###########################################################################
    # mouse

    if @mouse.button_right then rotate_right actor end
    if @mouse.button_left then rotate_left actor end

    if @mouse.click
      #@gtk_state.x = @mouse.click.point.x
      #@gtk_state.y = @mouse.click.point.y
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
    key_w = false
    key_a = false
    key_s = false
    key_d = false
    if @kb.key_down.truthy_keys.length > 0 then
      @kb.key_down.truthy_keys.each do |truth|
        #if truth == :shift then key_shift = true ; actor[:keypress_on] = @gtk_state.tick_count ; end
        if truth == :w then key_w = true ; actor[:keypress_on] = @gtk_state.tick_count ; end
        if truth == :a then key_a = true ; actor[:keypress_on] = @gtk_state.tick_count ; end
        if truth == :s then key_s = true ; actor[:keypress_on] = @gtk_state.tick_count ; end
        if truth == :d then key_d = true ; actor[:keypress_on] = @gtk_state.tick_count ; end
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
      set_impulse actor, 0, key_shift ? 8 : 4
    end
    if key_a then
      set_impulse actor, key_shift ? -8 : -4, 0
    end
    if key_s then
      set_impulse actor, 0, key_shift ? -8 : -4
    end
    if key_d then
      set_impulse actor, key_shift ? 8 : 4, 0
    end

    ###########################################################################
    # misc

    if @kb.key_down.r then
      $gtk.reset seed: rand(Time.now.sec)
    end
    if @kb.key_down.g then
      @state[:gravity?] = ! @state[:gravity?]
    end
    if @kb.key_down.b then
      @state[:wireframe?] = ! @state[:wireframe?]
    end
    if @kb.key_down.m then
      @state[:music?] = ! @state[:music?]
      if @state[:music?]
        play_bg_music
      else
        stop_bg_music
      end
    end

  end # of input
end # of Input
