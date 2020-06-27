require 'app/Test.rb'

def tick args
  args.outputs.labels << [ 100, 100, args.state.tick_count ]
  $gtk.reset if args.inputs.keyboard.key_down.r
end
