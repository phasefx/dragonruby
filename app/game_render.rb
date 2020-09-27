# frozen_string_literal: true

# output methods
module GameOutput
  def self.render(game, gtk)
    primitives = []
    primitives << render_actors(game[:actors])
    primitives << render_fps(game, gtk)
    primitives
  end

  def self.render_actors(_actors)
    primitives = []
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
    primitives << [
      gtk.grid.left,
      gtk.grid.top - text_height * 1,
      'R for Reset / M for Save / L for Load'
    ].labels
    primitives
  end
end
