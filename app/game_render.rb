# frozen_string_literal: true

# output methods
module GameOutput
  # more performant than arrays or hashes
  class Solid
    attr_accessor :x, :y, :w, :h, :r, :g, :b, :a

    def serialize
      [@x, @y, @w, @h, @r, @g, @b, @a]
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end

    def primitive_marker
      :solid
    end

    def intersect_rect?(rect, fuzz)
      [@x, @y, @w, @h].intersect_rect?(rect, fuzz)
    end

    # rubocop:disable Naming/MethodParameterName
    def initialize(x, y, w, h, color, a)
      self.x = x
      self.y = y
      self.w = w
      self.h = h
      self.r = color[0]
      self.g = color[1]
      self.b = color[2]
      self.a = a
    end
    # rubocop:enable Naming/MethodParameterName
  end

  # from https://venngage.com/blog/color-blind-friendly-palette/
  # Color Palettes for Color Blindness
  # Zesty Color Palette: #F5793A, #A95AA1, #85C0F9, #0F2080
  ZESTY1 = [245, 121, 58].freeze
  ZESTY2 = [169, 90, 161].freeze
  ZESTY3 = [133, 192, 249].freeze
  ZESTY4 = [15, 32, 128].freeze
  ZESTY = [ZESTY1, ZESTY2, ZESTY3, ZESTY4].freeze
  # Corporate Color Palette: #BDB8AD, #EBE7E0, #C6D4E1, #44749D
  CORP1 = [189, 184, 173].freeze
  CORP2 = [235, 231, 224].freeze
  CORP3 = [198, 212, 225].freeze
  CORP4 = [68, 116, 157].freeze
  CORP = [CORP1, CORP2, CORP3, CORP4].freeze
  # Elegant Color Palette: #ABC3C9, #E0DCD3, #CCBE9F, #382119
  ELEG1 = [171, 195, 201].freeze
  ELEG2 = [224, 220, 211].freeze
  ELEG3 = [204, 190, 159].freeze
  ELEG4 = [56, 33, 25].freeze
  ELEG = [ELEG1, ELEG2, ELEG3, ELEG4].freeze
  # Retro Color Palette: #601A4A, #EE442F, #63ACBE, #F9F4EC
  RETRO1 = [96, 26, 74].freeze
  RETRO2 = [238, 68, 47].freeze
  RETRO3 = [99, 172, 190].freeze
  RETRO4 = [249, 244, 236].freeze
  RETRO = [RETRO1, RETRO2, RETRO3, RETRO4].freeze

  PALETTES = [ZESTY, CORP, ELEG, RETRO].freeze
  BACKGROUND = [0, 0, 0].freeze
  TEXT = [255, 255, 255].freeze

  def self.render(game, gtk)
    primitives = []
    sounds = []
    sounds << 'media/MagicDark.wav' if game[:actors][:player][:became_visible]
    sounds << 'media/TransportUp.wav' if game[:actors][:player][:hit_target]
    primitives << render_actors(game[:actors], gtk)
    primitives << render_info(game, gtk)
    primitives << render_gameover(game, gtk)
    { primitives: primitives, sounds: sounds }
  end

  def self.render_actors(actors, gtk)
    primitives = []
    primitives << render_targets(actors[:targets])
    primitives << render_blocks(gtk.state.volatile[:blocks])
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
    primitives << blocks
    primitives
  end

  def self.render_targets(targets)
    primitives = []
    primitives << targets.map { |t| t[:label].label }
    primitives
  end

  def self.render_info(state, gtk)
    primitives = []
    text_height = gtk.gtk.calcstringbox('H')[1]
    targets_caught_this_level = state[:actors][:targets].select { |t| t[:caught] }.length
    targets_this_level = state[:actors][:targets].length
    targets_total_caught = state[:actors][:player][:total_targets_caught]
    fps_line = "FPS #{gtk.gtk.current_framerate.floor}  Tick #{gtk.tick_count}"
    score_line = "Score: #{targets_total_caught}"
    level_line = "Level: #{state[:level_index]}"
    targets_line = "Targets: #{targets_caught_this_level} out of #{targets_this_level}"
    time_line = "Time Remaining: #{state[:timer]}"
    whole_line = (state[:show_fps] ? fps_line + ' ' : '') + "#{score_line} #{level_line} #{targets_line} #{time_line}"
    primitives << [gtk.grid.left, gtk.grid.top - text_height * 0, whole_line, TEXT].labels
    if targets_caught_this_level >= targets_this_level
      next_level = 'Next Level'
      text_size = gtk.gtk.calcstringbox(next_level)
      primitives << [
        -text_size.x.half,
        text_size.y.half,
        next_level,
        TEXT
      ].labels
    end
    unless state[:actors][:player][:click_count].positive? || state[:game_over]
      instructions = 'left-click or hold left-click to find hidden targets'
      text_size = gtk.gtk.calcstringbox(instructions)
      primitives << [
        -text_size.x.half,
        text_size.y.half,
        instructions,
        TEXT
      ].labels
    end
    primitives
  end

  def self.render_gameover(state, gtk)
    primitives = []
    return primitives unless state[:game_over]

    string = 'Finis.  Right-click to restart' unless MINIGAME
    string = 'Finis.  Right-click for next mini-game' if MINIGAME
    text_size = gtk.gtk.calcstringbox(string)
    primitives << [
      -text_size.x.half,
      text_size.y.half,
      string,
      TEXT
    ].labels
    primitives
  end
end
