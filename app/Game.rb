class Game
  #############################################################################
  # setup

  include Actor
  include Audio
  include Input
  include Level
  include Logic
  include Render

  def initialize args

    @args = args
    @kb = @args.inputs.keyboard
    @mouse = @args.inputs.mouse
    @state = {}

    @state[:sprite_path] = {
      :monster => "sprites/DungeonAssetPack/SpriteFolder/Monsters/monster"
    }
    @state[:keyup_delay] = 10
    @state[:wireframe?] = false
    @state[:gravity?] = true
    @state[:music?] = true
    load_actors
    render_background
    play_bg_music
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

  def state
    puts "state called"
  end

  #############################################################################
  # game loop

  def tick
    render
    intelligence
    physics
  end # of tick

end # of class Game
