def level_001
    [{
      :intend_x_dir => 0,
      :intend_y_dir => 0,
      :speed_x => rand(5) + 5,
      :speed_y => rand(5) + 5,
      :collision_x => false,
      :collision_y => false,
      :x => $args.grid.rect[2].half + 128 + rand(400),
      :y => $args.grid.rect[3].half + 101 + rand(400),
      :render_z => rand(2),
      :collision_z => rand(2),
      :proposed_x => $args.grid.rect[2].half + 128 + rand(400),
      :proposed_y => $args.grid.rect[3].half + 101 + rand(400),
      :w => 128,
      :h => 101,
      :rotation => 0,
      :rotated_on => 0,
      :gravity? => false,
      :player? => false,
      :ai_routine => :horizontal,
      :ai_hdir => rand(3) - 1,
      :sprite_idx => 2,
      :sprite_type => :monster
    }]
end
