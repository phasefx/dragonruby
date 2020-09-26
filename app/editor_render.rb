# frozen_string_literal: true

# output methods
module EditorOutput
  def self.render(game, gtk)
    primitives = []
    primitives << render_editor_grid(game, gtk)
    primitives << game[:actors][:ship].map { |p| render_ship_part(p) }
    primitives << render_fps(game, gtk)
    primitives << render_inventory(game, gtk)
    primitives
  end

  def self.render_fps(state, gtk)
    primitives = []
    text_height = gtk.gtk.calcstringbox('H')[1]
    primitives << if state[:show_fps]
                    [
                      gtk.grid.left,
                      gtk.grid.top - text_height * 0,
                      "FPS #{gtk.gtk.current_framerate.floor}  Tick #{gtk.tick_count} Level #{state[:current_level]}"
                    ].labels
                  else
                    [
                      gtk.grid.left,
                      gtk.grid.top - text_height * 0,
                      "Level #{state[:current_level]}"
                    ].labels
                  end
    primitives
  end
end
