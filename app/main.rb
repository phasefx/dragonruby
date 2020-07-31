TEXT_HEIGHT = $gtk.calcstringbox("H")[1]

def init
    $gtk.args.state.my_bullets = []
    $gtk.args.state.my_targets = []
    $gtk.args.state.solids = []
    $gtk.args.state.labels = []
    $gtk.args.state.my_targets << [ 500, 500, 600, 600, 255, 0, 0]
    $gtk.args.state.my_targets << [ 100, 100, 140, 200, 255, 0, 0]
end

def my_tick args
  init if args.state.tick_count == 0
  if args.inputs.keyboard.key_up.b then
      args.state.my_bullets << [ rand(1280), 0, 5, 5, 0, 0, 0 ]
  end
    if args.inputs.keyboard.key_up.t then
      args.state.my_targets << [ rand(1280), rand(760), rand(100)+10, rand(100) + 10, rand(128)+128, rand(128)+128, rand(128)+128 ]
  end
  args.state.solids << args.state.my_targets
  args.state.solids << args.state.my_bullets
  args.state.labels << [0, args.grid.top - TEXT_HEIGHT * 0, 'B for random bullet' ]
  args.state.labels << [0, args.grid.top - TEXT_HEIGHT * 1, 'T for random target' ]
  args.state.labels << [0, args.grid.top - TEXT_HEIGHT * 2, 'P for pause' ]
  args.state.labels << [0, args.grid.top - TEXT_HEIGHT * 3, 'R for run' ]
  args.state.labels << [0, args.grid.top - TEXT_HEIGHT * 4, 'S for step' ]
  args.state.my_bullets.each do |b|
      b[1] += 5;
      args.state.my_targets = args.state.my_targets.reject {
          |t| t.intersect_rect? b
      }
  end
  args.state.my_bullets = args.state.my_bullets.reject {
      |b| b[1] > 768
  }
end

$debugging = :off

def debug_keys args
  if args.inputs.keyboard.key_down.p
    $debugging = :paused
    puts 'paused'
  end
  if args.inputs.keyboard.key_down.r
    $debugging = :off
    puts 'unpaused'
  end
  if args.inputs.keyboard.key_down.s
    $debugging = :step
    puts 'step'
  end
end

def tick args
  debug_keys args
  case $debugging
  when :paused
    args.outputs.solids << args.state.solids
    args.outputs.labels << args.state.labels
  else
    args.state.solids = []
    args.state.labels = []
    my_tick args
    args.outputs.solids << args.state.solids
    args.outputs.labels << args.state.labels
    $debugging = :paused if $debugging == :step
  end
end
