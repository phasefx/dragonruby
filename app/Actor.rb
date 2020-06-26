module Actor

  def player
    {
      :intend_x_dir => 0,
      :intend_y_dir => 0,
      :speed_x => 10,
      :speed_y => 10,
      :collision_x => false,
      :collision_y => false,
      :x => @args.grid.rect[2].half,
      :y => @args.grid.rect[3].half,
      :render_z => 1,
      :collision_z => 1,
      :proposed_x => @args.grid.rect[2].half,
      :proposed_y => @args.grid.rect[3].half,
      :w => 128,
      :h => 101,
      :rotation => 0,
      :rotated_on => 0,
      :gravity? => true,
      :player? => true,
      :ai_routine => :player,
      :sprite_idx => 1,
      :sprite_type => :monster
    }
  end

  def load_actors
    @args.state.player = player
    @args.state.actors = []
      .concat([@args.state.player])
      .concat(m_ghost)
      .concat(m_ghost)
      .sort { |a,b| a[:render_z] <=> b[:render_z] }
  end

end # of Actor
