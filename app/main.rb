$gtk.reset

class PhaseFX
  #############################################################################
  # setup
  
  def initialize args
    @args = args
    @args.state.rotation = 0
    @args.state.x = 0
    @args.state.y = 0
    @args.state.sprite_idx = 1
  end

  def serialize
    {
      :rotation => @args.state.rotation,
      :x => @args.state.x,
      :y => @args.state.y
    }
  end

  def inspect
    serialize.to_s
  end

  def to_s
    serialize.to_s
  end

  #############################################################################
  # collect input

  def input
    if @args.inputs.mouse.click then
      @args.state.x = @args.inputs.mouse.click.point.x
      @args.state.y = @args.inputs.mouse.click.point.y
    end
    if @args.inputs.keyboard.key_held.right
      @args.state.rotation -= 1
    end
    if @args.inputs.keyboard.key_held.left
      @args.state.rotation += 1
    end
    if @args.inputs.keyboard.key_down.up
        @args.state.sprite_idx += 1
        puts "sprite_idx #{@args.state.sprite_idx}"
    end
    if @args.inputs.keyboard.key_down.down
        @args.state.sprite_idx -= 1
        puts "sprite_idx #{@args.state.sprite_idx}"
    end
  end

  #############################################################################
  # handle the game logic

  def logic
    #@args.state.rotation -= 0.5
  end

  #############################################################################
  # draw stuff
 
  def render
    render_something
  end
   
  def render_something
    #@args.outputs.sprites << [100, 100,    32,     64, "sprites/circle-blue.png"]
    #@args.outputs.labels << [@args.state.x, @args.state.y, "@", 255, 0, 0]
    #@args.outputs.sprites << [ @args.state.x-64, @args.state.y-50, 128, 101, 'dragonruby.png', @args.state.rotation ]
    @args.outputs.sprites << {
      x: @args.state.x-64,
      y: @args.state.y-50,
      w: 128,
      h: 101,
      path: "sprites/DungeonAssetPack/SpriteFolder/Monsters/monster#{@args.state.sprite_idx}.png",
      #path: "dragonruby.png",
      angle: @args.state.rotation,
      a: 255,
      #r: @args.state.rotation.abs.mod(255),
      r: 255,
      g: 255,
      b: 255,
      tile_x:  0,
      tile_y:  0,
      tile_w: -1,
      tile_h: -1,
      flip_vertically: false,
      flip_horizontally: false,
      angle_anchor_x: 0.5,
      angle_anchor_y: 0.5
    }
  end


  #############################################################################
  # game loop

  def tick
    render
    input
    logic
  end

end

###############################################################################
# main

def tick args
  args.state.game ||= PhaseFX.new args
  args.state.game.tick

end
