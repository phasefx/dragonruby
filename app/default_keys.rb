module DefaultKeys
  def default_keys
    @gtk_kb.key_down.truthy_keys.each do |key|
      case key
      when :six
        set_state(:paint)
      when :seven
        set_state(:palette)
      end
    end # of truthy_keys.each
  end # of def default_keys
end # of module DefaultKeys
