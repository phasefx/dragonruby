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

  def self.text_dimensions(string)
    $gtk.calcstringbox(string,TEXT_SIZE,'app/Eighty-Four.ttf')
  end

  def self.render(game, gtk)
    primitives = []
    primitives << render_buttons(game[:buttons], gtk)
    primitives << render_display(game, gtk)
    primitives
  end

  def self.render_buttons(buttons, _gtk)
    primitives = []
    primitives << buttons
    primitives << buttons.each_with_index.map do |b, idx|
      {
         x: b.x + b.w.half,
         y: b.y + b.h.half.half*3.5,
         text: idx+1,
         size_enum: TEXT_SIZE,
         alignment_enum: 1,
         r: 0, g: 0, b: 0,
         font: "app/Eighty-Four.ttf" }.label
    end
    primitives
  end

  def self.render_display(game, gtk)
    primitives = []
    text_height = text_dimensions('0123456789_').y
    primitives << {
       x: 0,
       y: gtk.grid.top - text_height * 0,
       text: game[:target_buffer].join(' '),
       size_enum: TEXT_SIZE,
       alignment_enum: 1,
       r: 0, g: 0, b: 0,
       font: "app/Eighty-Four.ttf" }.label
    input_display = game[:target_buffer].each_with_index.map do |n,i|
      if game[:input_buffer][i].nil?
        n.to_s.chars.map { '_' }.join
      else
        game[:input_buffer][i]
      end
    end.join(' ')
    primitives << {
       x: 0,
       y: gtk.grid.top - text_height * 1,
       text: input_display,
       size_enum: TEXT_SIZE,
       alignment_enum: 1,
       r: 0, g: 0, b: 0,
       font: "app/Eighty-Four.ttf" }.label
    primitives
  end
end
