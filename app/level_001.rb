def level_001
    [{
      :intend_x_dir => 0,
      :intend_y_dir => 0,
      :speed_x => 10,
      :speed_y => 10,
      :collision_x => false,
      :collision_y => false,
      :x => $args.grid.rect[2].half + 128 + rand(400),
      :y => $args.grid.rect[3].half + 101 + rand(400),
      :z => rand(2),
      :proposed_x => $args.grid.rect[2].half + 128,
      :proposed_y => $args.grid.rect[3].half + 101,
      :w => 128,
      :h => 101,
      :rotation => 0,
      :rotated_on => 0,
      :gravity? => false,
      :sprite_idx => 2,
      :sprite_type => :monster
    }]
end
