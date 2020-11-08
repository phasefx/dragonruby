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
  TEXT_SIZE = 30
  BACKGROUND_COLOR = [168, 168, 168].freeze
  CLICKED_COLOR_TEXT = {r: 0, g: 0, b: 0}.freeze
  HOVERED_COLOR_TEXT = {r: 0, g: 0, b: 0}.freeze
  NORMAL_COLOR_TEXT = {r: 0, g: 0, b: 0}.freeze
  CLICKED_COLOR_BG = {r: 245, g: 121, b: 58}.freeze
  HOVERED_COLOR_BG = {r: 128, g: 128, b: 128}.freeze
  NORMAL_COLOR_BG = {r: 0, g: 0, b: 0}.freeze
  SPRITE_NORMAL_COLOR_BG = {r: 168, g: 168, b: 168}.freeze

  def self.text_dimensions(string)
    $gtk.calcstringbox(string,TEXT_SIZE)
  end

  def self.render(game, gtk)
    primitives = []
    primitives << render_buttons(game[:buttons], game[:sound], gtk)
    primitives << render_display(game, gtk)
    primitives << render_borders(game[:buttons])
    
    audio = Hash[
      game[:buttons].each_with_index.map do |b, idx|
        if b[:audible] && !game[:canonical_audio][idx].nil?
          [idx, game[:canonical_audio][idx].clone]
        else
          []
        end
      end.reject { |a| a.length.zero? }
    ]

    {
      primitives: primitives,
      audio: audio
    }
  end

  def self.render_borders(buttons)
    primitives = []
    primitives << buttons
    buttons.each_with_index.map do |b, idx|
      primitives << b.clone.border
    end
    primitives
  end

  def self.render_buttons(buttons, sound, _gtk)
    primitives = []
    primitives << buttons
    buttons.each_with_index.map do |b, idx|
      if b[:clicked] || b[:hovered] || idx > 10
        primitives << b.clone.merge(
          case idx
          when 11
            if sound
              b[:clicked] ? CLICKED_COLOR_BG : (b[:hovered] ? HOVERED_COLOR_BG : SPRITE_NORMAL_COLOR_BG)
            else
              CLICKED_COLOR_BG
            end
          when 12
            if sound
              CLICKED_COLOR_BG
            else
              b[:clicked] ? CLICKED_COLOR_BG : (b[:hovered] ? HOVERED_COLOR_BG : SPRITE_NORMAL_COLOR_BG)
            end
          else
            b[:clicked] ? CLICKED_COLOR_BG : (b[:hovered] ? HOVERED_COLOR_BG : NORMAL_COLOR_BG)
          end
        ).solid
      end
    end
    primitives << buttons.each_with_index.map do |b, idx|
      case idx
      when 0..10
      {
         x: b.x + b.w.half,
         y: b.y + b.h.half.half*3.5 - 10,
         text: case idx
               when 10
                 '←'
               when 11 # these speaker icons are not in our stock font.ttf file
                 '🔇'
               when 12 # so we'll use sprites instead; see below
                 '🔈'
               else
                 idx
               end,
         size_enum: TEXT_SIZE,
         alignment_enum: 1 }.merge(
           b[:clicked] ? CLICKED_COLOR_TEXT : (b[:hovered] ? HOVERED_COLOR_TEXT : NORMAL_COLOR_TEXT)
         ).label
      else
      {
         x: b.x + (idx == 11 ? b.w.idiv(5) - 2 : b.w.half.half),
         y: b.y,
         w: 120,
         h: 120,
         path: case idx
               when 11
                 'app/muted-speaker_1f507.png'
               when 12
                 'app/speaker-high-volume_1f50a.png'
               end,
         }.merge(
           case idx
           when 11
           if sound
             b[:clicked] ? CLICKED_COLOR_TEXT : (b[:hovered] ? HOVERED_COLOR_TEXT : NORMAL_COLOR_TEXT)
           else
             b[:clicked] ? CLICKED_COLOR_TEXT : (b[:hovered] ? HOVERED_COLOR_TEXT : CLICKED_COLOR_TEXT)
           end
           when 12
           if sound
             b[:clicked] ? CLICKED_COLOR_TEXT : (b[:hovered] ? HOVERED_COLOR_TEXT : CLICKED_COLOR_TEXT)
           else
             b[:clicked] ? CLICKED_COLOR_TEXT : (b[:hovered] ? HOVERED_COLOR_TEXT : NORMAL_COLOR_TEXT)
           end
           end
         ).sprite
      end
    end
    primitives
  end

  def self.render_display(game, gtk)
    primitives = []
    text_height = text_dimensions('0123456789_').y
    primitives << {
       x: 0,
       y: gtk.grid.top - text_height * 0 - 20,
       text: game[:current_level][:display_target].join(' '),
       size_enum: TEXT_SIZE,
       alignment_enum: 1,
       r: 0, g: 0, b: 0 }.label
    input_display = game[:current_level][:target_buffer].each_with_index.map do |n,i|
      if game[:input_buffer][i].nil?
        n.to_s.chars.map { '_' }.join
      else
        game[:input_buffer][i]
      end
    end.join(' ')
    primitives << {
       x: 0,
       y: gtk.grid.top - text_height * 1 - 20,
       text: input_display,
       size_enum: TEXT_SIZE,
       alignment_enum: 1,
       r: 0, g: 0, b: 0 }.label
    primitives
  end
end
