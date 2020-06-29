module Level
  def m_ghost
    [{
      :intended_impulse => Vector.new(0, 0),
      :intended_on => 0,
      :impulsed_on => 0,
      :speed_limit_x => 40,
      :speed_limit_y => 20,
      :collision_x => false,
      :collision_y => false,
      :render_z => rand(2),
      :collision_z => rand(2),
      :keypress_on => 0,
      :particle => Particle.new(
        Vector.new(
          @gtk_grid.rect[2].half + rand(100),
          @gtk_grid.rect[3].half + rand(100)), # position
        Vector.new(0,0),                       # next_position
        Vector.new(0,0),                       # velocity
        Vector.new(0,0),                       # next_velocity
        100
      ),
      :w => 128,
      :h => 101,
      :rotation => 0,
      :rotated_on => 0,
      :gravity? => false,
      :player? => false,
      :ai_routine => :horizontal,
      :ai_hdir => rand(10) > 5 ? 1 : -1,
      :sprite_idx => 2,
      :sprite_type => :monster
    }]
  end
end
