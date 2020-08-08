module PaletteInput
  def palette_keys
    @gtk_kb.key_down.truthy_keys.each do |key|
      case key
      when :w
        @palette_key_w_down_at = @gtk_state.tick_count
        @palette_coords = [@palette_coords.x, bound(@palette_coords.y + 1, 0, 32 - INITIAL_GRID_SIZE)]
      when :s
        @palette_key_s_down_at = @gtk_state.tick_count
        @palette_coords = [@palette_coords.x, bound(@palette_coords.y - 1, 0, 32 - INITIAL_GRID_SIZE)]
      when :d
        @palette_key_d_down_at = @gtk_state.tick_count
        @palette_coords = [bound(@palette_coords.x + 1, 0, 32 - INITIAL_GRID_SIZE), @palette_coords.y]
      when :a
        @palette_key_a_down_at = @gtk_state.tick_count
        @palette_coords = [bound(@palette_coords.x - 1, 0, 32 - INITIAL_GRID_SIZE), @palette_coords.y]
      when :escape
        set_state(:paint)
      when :six
        set_state(:paint)
      end
    end # of key_down.truthy_keys.each
    @gtk_kb.key_held.truthy_keys.each do |key|
      case key
      when :w
        if @gtk_state.tick_count - @palette_key_w_down_at > KEY_HELD_DELAY
          @palette_coords = [@palette_coords.x, bound(@palette_coords.y + 1, 0, 32 - INITIAL_GRID_SIZE)]
        end
      when :s
        if @gtk_state.tick_count - @palette_key_s_down_at > KEY_HELD_DELAY
          @palette_coords = [@palette_coords.x, bound(@palette_coords.y - 1, 0, 32 - INITIAL_GRID_SIZE)]
        end
      when :d
        if @gtk_state.tick_count - @palette_key_d_down_at > KEY_HELD_DELAY
          @palette_coords = [bound(@palette_coords.x + 1, 0, 32 - INITIAL_GRID_SIZE), @palette_coords.y]
        end
      when :a
        if @gtk_state.tick_count - @palette_key_a_down_at > KEY_HELD_DELAY
          @palette_coords = [bound(@palette_coords.x - 1, 0, 32 - INITIAL_GRID_SIZE), @palette_coords.y]
        end
      end
    end # of key_held.truthy_keys.each
  end # of def palette_keys
end # of module PaletteInput
