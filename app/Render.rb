module Render

  #############################################################################
  # draw stuff
 
  def render
    # render_background -> done once in init
    @state[:actors].each_with_index {|actor,idx| render_actor actor,idx }
    if @state[:wireframe?] then
      #:x => @args.grid.rect[2].half,
      @args.outputs.labels << [ @args.grid.rect[0], @args.grid.rect[3], "Player (#{@args.state.player.x},#{@args.state.player.y})" ]
    end
  end # of render
  
  def render_background
    # for the static_ variants, you only want to push into these once, unless
    # you're going to manually clear with each tick
    #@args.outputs.static_solids.clear;
    @args.outputs.static_solids << {
      x:  @args.grid.rect[0],
      y:  @args.grid.rect[1],
      w:  @args.grid.rect[2],
      h:  @args.grid.rect[3],
      r:    0,
      g:  255,
      b:    0,
      a:  64
    }.solid
  end # of render_background

  def render_actor actor, idx
    path = "#{@state[:sprite_path][actor[:sprite_type]]}#{actor[:sprite_idx]}.png"
    face_left = actor[:intend_x_dir] < 0
    if actor[:player?] then
      if @kb.directional_vector then
        face_left = @kb.directional_vector[0] < 0
      elsif
        face_left = @mouse.x < actor.x
      end
    end
    if @state[:wireframe?]
      @args.outputs.borders << {
        x: actor.x-actor.w.half,
        y: actor.y-actor.h.half,
        w: actor.w,
        h: actor.h,
        r: 255,
        g: 0,
        b: 0,
        a: 128
      }
      @args.outputs.labels << {
        x: actor.x-actor.w.half,
        y: actor.y-actor.h.half,
        text: 'collision-z: ' + actor[:collision_z].to_s
      }
    end
    @args.outputs.primitives << {
      x: actor.x-actor.w.half,
      y: actor.y-actor.h.half,
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
