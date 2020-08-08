module PaintInput
  def paint_keys
    @gtk_kb.key_down.truthy_keys.each do |key|
      case key
      when :escape
        set_state(:default)
      when :seven
        set_state(:palette)
      end
    end # of truthy_keys.each
  end # of def paint_keys
end # of module PaintInput
