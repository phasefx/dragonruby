module Actor

  def player
    {
      :intend_x_dir => 0,
      :intend_y_dir => 0,
      :speed_x => 10,
      :speed_y => 10,
      :collision_x => false,
      :collision_y => false,
      :x => @gtk_grid.rect[2].half,
      :y => @gtk_grid.rect[3].half,
      :render_z => 1,
      :collision_z => 1,
      :keypress_on => 0,
      :proposed_x => @gtk_grid.rect[2].half,
      :proposed_y => @gtk_grid.rect[3].half,
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
    @state[:player] = player
    @state[:actors] = []
      .concat([@state[:player]])
      .concat(m_ghost)
      .concat(m_ghost)
      .sort { |a,b| a[:render_z] <=> b[:render_z] }
  end

end # of Actor
