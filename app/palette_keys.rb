module PaletteKeys
  def palette_keys
    @gtk_kb.key_down.truthy_keys.each do |key|
      case key
      when :up
        @palette_coords = [ @palette_coords.x, bound(@palette_coords.y + 1, 0, 32 - INITIAL_GRID_SIZE) ]
      when :down
        @palette_coords = [ @palette_coords.x, bound(@palette_coords.y - 1, 0, 32 - INITIAL_GRID_SIZE) ]
      when :right
        @palette_coords = [ bound(@palette_coords.x + 1, 0, 32 - INITIAL_GRID_SIZE), @palette_coords.y ]
      when :left
        @palette_coords = [ bound(@palette_coords.x - 1, 0, 32 - INITIAL_GRID_SIZE), @palette_coords.y ]
      when :escape
        set_state(:paint)
      when :six
        set_state(:paint)
      end
    end # of truthy_keys.each
  end # of def palette_keys
end # of module PaletteKeys
