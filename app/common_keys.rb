module CommonKeys
  def common_keys
    @gtk_kb.key_down.truthy_keys.each do |key|
      case key
      when :hyphen
        @common_key_hyphen_down_at = @gtk_state.tick_count
        @grid_segment_size = bound(@grid_segment_size-1,@min_grid_segment_size,@max_grid_segment_size)
      when :equal_sign
        @common_key_equal_sign_down_at = @gtk_state.tick_count
        @grid_segment_size = bound(@grid_segment_size+1,@min_grid_segment_size,@max_grid_segment_size)
      when :g
        @show_grid_outline = !@show_grid_outline
      end
    end # of key_down.truthy_keys.each
    @gtk_kb.key_held.truthy_keys.each do |key|
      case key
      when :hyphen
        if @gtk_state.tick_count - @common_key_hyphen_down_at > KEY_HELD_DELAY
          @grid_segment_size = bound(@grid_segment_size-1,@min_grid_segment_size,@max_grid_segment_size)
        end
      when :equal_sign
        if @gtk_state.tick_count - @common_key_equal_sign_down_at > KEY_HELD_DELAY
          @grid_segment_size = bound(@grid_segment_size+1,@min_grid_segment_size,@max_grid_segment_size)
        end
      end
    end # of key_held.truthy_keys.each
  end # of def common_keys
end # of module CommonKeys
