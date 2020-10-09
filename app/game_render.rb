# frozen_string_literal: true

# output methods
module GameOutput
  # Create type with ALL sprite properties AND primitive_marker
  class Sprite
    attr_accessor :x, :y, :w, :h, :path, :angle, :a, :r, :g, :b,
                  :source_x, :source_y, :source_w, :source_h,
                  :tile_x, :tile_y, :tile_w, :tile_h,
                  :flip_horizontally, :flip_vertically,
                  :angle_anchor_x, :angle_anchor_y

    def primitive_marker
      :sprite
    end
  end

  # more performant than arrays or hashes
  class Background < Sprite
    def serialize
      [@x, @y, @w, @h, @path]
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end

    def initialize(path)
      @x = $gtk.args.grid.left
      @y = $gtk.args.grid.bottom
      @w = $gtk.args.grid.w
      @h = $gtk.args.grid.h
      @path = path
    end
  end

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

    def rect
      [@x, @y, @w, @h]
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

  # more performant than arrays or hashes
  class Label
    attr_accessor :x, :y, :text, :size_enum, :alignment_enum, :r, :g, :b, :a, :font, :text_size

    def serialize
      [@x, @y, @text, @size_enum, @alignment_enum, @r, @g, @b, @a, @font]
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end

    def primitive_marker
      :label
    end

    def rect
      [@x - @text_size[0].half, @y - @text_size[1], @text_size[0], @text_size[1]]
    end

    # rubocop:disable Naming/MethodParameterName
    def initialize(x, y, text, color, a)
      self.x = x
      self.y = y
      self.text = text
      self.size_enum = 3
      self.alignment_enum = 1
      self.font = 'font.ttf'
      self.r = color[0]
      self.g = color[1]
      self.b = color[2]
      self.a = a
      self.text_size = $gtk.calcstringbox(text)
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

    primitives << gtk.state.volatile[:backgrounds][game[:bg_index]]

    primitives << render_actors(game[:actors])

    primitives << render_info(game, gtk)

    primitives << render_gameover(game, gtk)

    sounds << 'media/MagicDark.wav' if game[:actors][:player][:became_visible]
    sounds << 'media/TransportUp.wav' if game[:actors][:player][:hit_target]
    sounds << 'media/SpookyHigh.wav' if game[:desire_next_level]
    if game[:game_over]
      sounds << 'media/SpookyLow.wav' unless game[:game_over_sound_played]
      game[:game_over_sound_played] = true
    end

    { primitives: primitives, sounds: sounds }
  end

  def self.render_actors(actors)
    primitives = []
    # blocks and targets break form here and are put into static_primitives during next_level call
    primitives << render_player(actors[:player])
    primitives
  end

  def self.render_player(player)
    primitives = []
    return primitives unless player[:visible]

    primitives << player[:rect].border
    primitives
  end

  def self.render_info(state, gtk)
    primitives = []
    text_height = gtk.gtk.calcstringbox('H')[1]
    targets_caught_this_level = state[:actors][:targets].select { |t| t[:caught] }.length
    targets_this_level = state[:actors][:targets].length
    _targets_total_caught = state[:actors][:player][:total_targets_caught]
    fps_line = "FPS #{gtk.gtk.current_framerate.floor}  Tick #{gtk.tick_count}"
    score_line = "Score: #{state[:actors][:player][:score]}"
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
      instructions = case $gtk.platform # Emscripten, Windows, Mac OS X, Linux, Android, iOS
                     when 'Android'
                       'touch screen to find hidden targets'
                     when 'iOS'
                       'touch screen to find hidden targets'
                     else
                       'left-click or hold left-click to find hidden targets'
                     end
      text_size = gtk.gtk.calcstringbox(instructions)
      primitives << [
        -text_size.x.half,
        text_size.y.half * 2,
        instructions,
        TEXT
      ].labels
    end
    primitives
  end

  def self.render_gameover(state, gtk)
    primitives = []
    return primitives unless state[:game_over]

    substring = 'to restart' unless MINIGAME
    substring = 'for next mini-game' if MINIGAME
    string = case $gtk.platform # Emscripten, Windows, Mac OS X, Linux, Android, iOS
             when 'Android'
               "capture remaining targets #{substring}"
             when 'iOS'
               "capture remaining targets #{substring}"
             else
               "right-click or capture remaining targets #{substring}"
             end
    text_size = gtk.gtk.calcstringbox(string)
    primitives << [
      -text_size.x.half,
      text_size.y.half * 4,
      string,
      TEXT
    ].labels
    primitives
  end
end
