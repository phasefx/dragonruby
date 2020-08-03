module PaletteKeys
  def palette_keys
    @gtk_kb.key_down.truthy_keys.each do |key|
      case key
      when :escape
        set_state(:paint)
      when :six
        set_state(:paint)
      end
    end # of truthy_keys.each
  end # of def palette_keys
end # of module PaletteKeys
