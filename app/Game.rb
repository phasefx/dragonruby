class Game
  #############################################################################
  # setup

  attr_accessor :state

  include Actor
  include Audio
  include Input
  include Level
  include Logic
  include Physics
  include Render

  def initialize args

    @gtk_inputs = args.inputs
    @gtk_outputs = args.outputs
    @gtk_state = args.state
    @gtk_grid = args.grid
    @kb = @gtk_inputs.keyboard
    @mouse = @gtk_inputs.mouse
    @state = {}
    @state[:sprite_path] = {
      :monster => "sprites/DungeonAssetPack/SpriteFolder/Monsters/monster"
    }
    @state[:keyup_delay] = 10
    @state[:wireframe?] = false
    @state[:gravity?] = true
    @state[:music?] = false
    load_actors
    render_background
    play_bg_music if @state[:music?]
  end # of initialize

  def serialize
    {
      :actors => @state[:actors]
    }
  end # of serialize

  def inspect
    serialize.to_s
  end # of inspect

  def to_s
    serialize.to_s
  end # of to_s

  #############################################################################
  # game loop

  def tick
    render
    intelligence
    physics
  end # of tick

end # of class Game
