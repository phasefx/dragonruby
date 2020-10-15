def tick args
  $x ||= 100
  $y ||= 100
  $i ||= 0
  args.outputs.labels << [$x,$y,$i]
  if args.inputs.mouse.click && args.inputs.mouse.button_left
    $x = rand(100)+100
    $y = rand(100)+100
    unless $i == 0
      $i -= 1
      args.audio[$i] = args.state.canonical_audio[$i].clone unless args.state.canonical_audio[$i].nil?
    end
  end
  if args.inputs.mouse.click && args.inputs.mouse.button_right
    $x = rand(100)+100
    $y = rand(100)+100
    $i += 1
    args.state.canonical_audio[$i] = {
      filename: 'app/C3.wav',
      gain: 1.0,
      pitch: $i.to_f,
      looping: false,
      paused: false
    }
    args.audio[$i] = args.state.canonical_audio[$i].clone
  end
end

$gtk.reset
