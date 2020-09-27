# frozen_string_literal: true

# from https://venngage.com/blog/color-blind-friendly-palette/
# Color Palettes for Color Blindness
#     Zesty Color Palette: #F5793A, #A95AA1, #85C0F9, #0F2080
#     rgb(245, 121, 58)
#     rgb(169, 90, 161)
#     rgb(133, 192, 249)
#     rgb(15, 32, 128)
# Corporate Color Palette: #BDB8AD, #EBE7E0, #C6D4E1, #44749D
#   Elegant Color Palette: #ABC3C9, #E0DCD3, #CCBE9F, #382119
#     Retro Color Palette: #601A4A, #EE442F, #63ACBE, #F9F4EC

# output methods
module GameOutput
  ZESTY1 = [245, 121, 58].freeze
  ZESTY2 = [169, 90, 161].freeze
  ZESTY3 = [133, 192, 249].freeze
  ZESTY4 = [15, 32, 128].freeze
  BACKGROUND = [0, 0, 0].freeze
  TEXT = [255, 255, 255].freeze
  ZESTY = [ZESTY1, ZESTY2, ZESTY3, ZESTY4].freeze

  def self.render(game, gtk)
    primitives = []
    sounds = []
    sounds << 'media/MagicDark.wav' if game[:actors][:player][:became_visible]
    sounds << 'media/TransportUp.wav' if game[:actors][:player][:hit_target]
    primitives << render_actors(game[:actors])
    primitives << render_fps(game, gtk)
    { primitives: primitives, sounds: sounds }
  end

  def self.render_actors(actors)
    primitives = []
    primitives << render_targets(actors[:targets])
    primitives << render_blocks(actors[:blocks])
    primitives << render_player(actors[:player])
    primitives
  end

  def self.render_player(player)
    primitives = []
    return primitives unless player[:visible]

    primitives << player[:rect].border
    primitives
  end

  def self.render_blocks(blocks)
    primitives = []
    primitives << blocks.map { |b| [b[:rect], b[:color]].solid }
    primitives
  end

  def self.render_targets(targets)
    primitives = []
    primitives << targets.reject { |t| t[:captured] }.map { |t| t[:label].label }
    primitives
  end

  def self.render_fps(state, gtk)
    primitives = []
    text_height = gtk.gtk.calcstringbox('H')[1]
    targets_caught_this_level = state[:actors][:targets].select { |t| t[:caught] }.length
    targets_this_level = state[:actors][:targets].length
    targets_total_caught = state[:actors][:player][:total_targets_caught]
    primitives << if state[:show_fps]
                    [
                      gtk.grid.left,
                      gtk.grid.top - text_height * 0,
                      "FPS #{gtk.gtk.current_framerate.floor}  Tick #{gtk.tick_count} Score: #{targets_total_caught} Level: #{state[:level_index]} Targets: #{targets_caught_this_level} out of #{targets_this_level} Time Remaining: #{state[:timer]}",
                      TEXT
                    ].labels
                  else
                    [
                      gtk.grid.left,
                      gtk.grid.top - text_height * 0,
                      "Score: #{targets_total_caught} Level: #{state[:level_index]} Targets: #{targets_caught_this_level} out of #{targets_this_level} Time Remaining: #{state[:timer]}",
                      TEXT
                    ].labels
                  end
    primitives
  end
end
