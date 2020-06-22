$gtk.reset

class PhaseFX
  #############################################################################
  # setup
  
  def initialize args
    @args = args
    @args.state.rotation = 0
    @args.state.rotated_on = 0
    @args.state.player = {}
    @args.state.player.x = @args.grid.rect[2].idiv(2)
    @args.state.player.y = @args.grid.rect[3].idiv(2)
    @args.state.sprite_idx = 1
    @args.state.sprite_path = {
      :monsters => "sprites/DungeonAssetPack/SpriteFolder/Monsters/"
    }
    render_background
    play_bg_music
  end # of initialize

  def serialize
    {
      :rotation => @args.state.rotation,
      :x => @args.state.x,
      :y => @args.state.y
    }
  end # of serialize

  def inspect
    serialize.to_s
  end # of inspect

  def to_s
    serialize.to_s
  end # of to_s

  #############################################################################
  # collect input

  def input

    ###########################################################################
    # mouse

    if @args.inputs.mouse.click
      @args.state.x = @args.inputs.mouse.click.point.x
      @args.state.y = @args.inputs.mouse.click.point.y
    end

    ###########################################################################
    # arrow keys

    if @args.inputs.keyboard.key_held.right
      @args.state.rotation -= 1
      if @args.state.rotation < -360 then @args.state.rotation += 360 end
      @args.state.rotated_on = @args.state.tick_count
    end
    if @args.inputs.keyboard.key_held.left
      @args.state.rotation += 1
      if @args.state.rotation > 360 then @args.state.rotation -= 360 end
      @args.state.rotated_on = @args.state.tick_count
    end
    if @args.inputs.keyboard.key_down.up
        @args.state.sprite_idx += 1
        puts "sprite_idx #{@args.state.sprite_idx}"
    end
    if @args.inputs.keyboard.key_down.down
        @args.state.sprite_idx -= 1
        puts "sprite_idx #{@args.state.sprite_idx}"
    end
    if @args.inputs.keyboard.key_down.pagedown
        @args.state.sprite_idx = 1
        puts "sprite_idx #{@args.state.sprite_idx}"
    end
    if @args.inputs.keyboard.key_down.pageup
        @args.state.rotation = 0
    end

    ###########################################################################
    # WASD

    if @args.inputs.keyboard.key_held.w then @args.state.player.y += 10 end
    if @args.inputs.keyboard.key_held.s then @args.state.player.y -= 10 end
    if @args.inputs.keyboard.key_held.a then @args.state.player.x -= 10 end
    if @args.inputs.keyboard.key_held.d then @args.state.player.x += 10 end

    ###########################################################################
    # misc


  end # of input

  #############################################################################
  # handle the game logic

  def logic

    # slowly level out any rotation
    if @args.state.rotation > 0 and
        @args.state.tick_count > @args.state.rotated_on + 10
      then @args.state.rotation -= 0.5 end
    if @args.state.rotation < 0 and
        @args.state.tick_count > @args.state.rotated_on + 10
      then @args.state.rotation += 0.5 end

  end # of logic

  #############################################################################
  # audio stuff

  def play_bg_music
    @args.outputs.sounds << "music/A Long Way.ogg"
  end
 
  #############################################################################
  # draw stuff
 
  def render
    # render_background -> done once in init
    render_something
  end # of render
  
  def render_background
    puts "inside render_background"
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

  def render_something
    path = "#{@args.state.sprite_path[:monsters]}monster#{@args.state.sprite_idx}.png"
    face_left = false
    if @args.inputs.keyboard.directional_vector then
      face_left = @args.inputs.keyboard.directional_vector[0] < 0
    elsif
      face_left = @args.inputs.mouse.x < @args.state.player.x
    end
    @args.outputs.primitives << {
      x: @args.state.player.x-64,
      y: @args.state.player.y-50,
      w: 128,
      h: 101,
      path: path,
      angle: @args.state.rotation,
      a: 255,
      r: 255,
      g: 255,
      b: 255,
      tile_x:  0,
      tile_y:  0,
      tile_w: -1,
      tile_h: -1,
      flip_vertically: false,
      flip_horizontally: face_left,
      angle_anchor_x: 0.5,
      angle_anchor_y: 0.5
    }.sprite
  end # of render_something

  #############################################################################
  # game loop

  def tick
    render
    input
    logic
  end # of tick

end # of class PhaseFX

###############################################################################
# main

def tick args
  args.state.game ||= PhaseFX.new args
  args.state.game.tick
end # of tick
