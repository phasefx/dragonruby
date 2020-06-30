module Actor

  def player
    {
      :intended_impulse => Vector.new(0, 0),
      :intended_on => 0,
      :impulsed_on => 0,
      :speed_limit_x => 20,
      :speed_limit_y => 20,
      :collision_x => false,
      :collision_y => false,
      :render_z => 1,
      :collision_z => 0,
      :keypress_on => 0,
      :particle => Particle.new(
        Vector.new(
          @gtk_grid.rect[2].half - 100,
          @gtk_grid.rect[3].half - 100), # position
        Vector.new(0,0),                 # next_position
        Vector.new(0,0),                 # velocity
        Vector.new(0,0),                 # next_velocity
        100                              # mass
      ),
      :w => 128,
      :h => 101,
      :rotation => 0,
      :rotated_on => 0,
      :gravity? => true,
      :player? => true,
      :ai_routine => :player,
      :ai_hdir => 0,
      :sprite_idx => 1,
      :sprite_type => :monster
    }
  end

  def load_actors
    @state[:player] = player
    @state[:actors] = []
      .concat([@state[:player]])
      .concat(m_ghost)
      .sort { |a,b| a[:render_z] <=> b[:render_z] }
  end

end # of Actor
