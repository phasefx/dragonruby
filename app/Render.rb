module Render

  #############################################################################
  # draw stuff
 
  def render
    # render_background -> done once in init
    @state[:actors].each_with_index {|actor,idx| render_actor actor,idx }
    if @state[:wireframe?] then
      #:x => @gtk_grid.rect[2].half,
      @gtk_outputs.labels << [
        @gtk_grid.rect[0],
        @gtk_grid.rect[3],
        "Player (#{@state[:player][:particle].position.x},#{@state[:player][:particle].position.y})"
      ]
    end
  end # of render
  
  def render_background
    # for the static_ variants, you only want to push into these once, unless
    # you're going to manually clear with each tick
    #@gtk_outputs.static_solids.clear;
    @gtk_outputs.static_solids << {
      x:  @gtk_grid.rect[0],
      y:  @gtk_grid.rect[1],
      w:  @gtk_grid.rect[2],
      h:  @gtk_grid.rect[3],
      r:    0,
      g:  255,
      b:    0,
      a:  64
    }.solid
  end # of render_background

  def render_actor actor, idx
    path = "#{@state[:sprite_path][actor[:sprite_type]]}#{actor[:sprite_idx]}.png"
    face_left = actor[:intended_impulse].x < 0
    if actor[:player?] then
      if @kb.directional_vector then
        face_left = @kb.directional_vector[0] < 0
      elsif
        face_left = @mouse.x < actor.x
      end
    end
    if @state[:wireframe?]
      @gtk_outputs.borders << {
        x: actor[:particle].position.x-actor.w.half,
        y: actor[:particle].position.y-actor.h.half,
        w: actor.w,
        h: actor.h,
        r: 255,
        g: 0,
        b: 0,
        a: 128
      }
      @gtk_outputs.labels << {
        x: actor[:particle].position.x-actor.w.half,
        y: actor[:particle].position.y-actor.h.half,
        text: 'collision-z: ' + actor[:collision_z].to_s
      }
    end
    @gtk_outputs.primitives << {
      x: actor[:particle].position.x-actor.w.half,
      y: actor[:particle].position.y-actor.h.half,
      w: actor.w,
      h: actor.h,
      path: path,
      angle: actor[:rotation],
      a: 255,
      r: 255,
      g: 255,
      b: 128,
      tile_x:  0,
      tile_y:  0,
      tile_w: -1,
      tile_h: -1,
      flip_vertically: false,
      flip_horizontally: face_left,
      angle_anchor_x: 0.5,
      angle_anchor_y: 0.5
    }.sprite
  end # of render_actor
end # of Render
