# experimenting with debug controls

not a serious game, the main point of this is to see how easy it would be to step through DragonRuby GTK code frame by frame

```rb
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
```
