LEVEL_001 = 'app/level_001.rb'
require LEVEL_001

class Game
  #############################################################################
  # setup

  include Input
  include Logic
  include Render
  include Audio

  def initialize args
    @args = args
    @kb = @args.inputs.keyboard
    @mouse = @args.inputs.mouse
    @args.state.player = {
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
    @args.state.actors = []
      .concat([@args.state.player])
      .concat(level_001)
      .concat(level_001)
      .sort { |a,b| a[:render_z] <=> b[:render_z] }
    @args.state.sprite_path = {
      :monster => "sprites/DungeonAssetPack/SpriteFolder/Monsters/monster"
    }
    @args.state.keyup_delay = 10
    @args.state[:wireframe?] = false
    @args.state[:gravity?] = true
    render_background
    #play_bg_music
  end # of initialize

  def serialize
    {
      :actors => @args.state.actors
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
