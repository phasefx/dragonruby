# frozen_string_literal: true

require 'readline'

# rubocop:disable Metric/MethodLength
def to_dragonruby(cmd)
  relative_path = Dir.pwd.split(%r{\/})[-2..-1].join('/')
  File.write('repl.out', '')
  File.open('repl.rb', 'w') do |f|
    f.write "repl do\n"
    f.write "\tdef to_shell(s)\n"
    f.write "\t\t$gtk.write_file '#{relative_path}/repl.out', s.to_s\n"
    f.write "\tend\n"
    f.write "\tresult = #{cmd}\n"
    f.write "\tto_shell(result)\n"
    f.write "end\n"
  end
end
# rubocop:enable Metric/MethodLength

comp = proc do |s|
  last_period_index = s.rindex('.')
  prefix = s
  prefix = s[(last_period_index + 1)..-1] if last_period_index
  prefix = prefix.gsub(/'/, '\'')
  obj = s[0...last_period_index]
  to_dragonruby "#{obj}.autocomplete_methods.map(&:to_s).select { |m| m.start_with? '#{prefix}' }"
  sleep 1 # race condition; could use Guard gem, etc.

  # rubocop:disable Security/Eval
  results = eval File.read('repl.out')
  # rubocop:enable Security/Eval
  results
end

Readline.completion_append_character = ' '
Readline.completion_proc = comp

while (input = Readline.readline('> ', true))
  Readline::HISTORY.pop if input == ''
  to_dragonruby(input)
  sleep 1 # race condition; could use Guard gem, etc.
  puts File.read('repl.out')
end
