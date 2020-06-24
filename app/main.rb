class Turtle
  def initialize args
    @args = args
    @args.state[:pen] = :up
    @args.state.angle = 0
    # center as origin
    #@args.state.coord = CartesianCoordinate.new 0, 0
    # bottomleft as origin
    @args.state.coord = CartesianCoordinate.new @args.grid.rect[2].half, @args.grid.rect[3].half
    @args.render_target(:turtle).lines << [[ 0, 1, 20, 1, 0, 0, 0 ], [ 0, 1, 10, 20, 0, 0, 0 ], [ 10, 20, 20, 1, 0, 0, 0 ]]
  end

  def serialize() {} end
  def inspect() serialize.to_s end
  def to_s() serialize.to_s end

  def render_turtle
    @args.outputs.sprites << {
      x: @args.state.coord.x,
      y: @args.state.coord.y,
      w: 20,
      h: 20,
      angle: @args.state.angle,
      path: :turtle,
      source_x: 0,
      source_y: 0,
      source_w: 20,
      source_h: 20
    }
  end

  def tick
    # center as origin
    # @args.outputs.labels << [ @args.grid.rect[0], -@args.grid.rect[1], "Turtle (#{@args.state.coord.x},#{@args.state.coord.y})" ]
    # bottomleft as origin
    @args.outputs.labels << [ @args.grid.rect[0], @args.grid.rect[3], "Turtle (#{@args.state.coord.x},#{@args.state.coord.y})" ]
    render_turtle
  end
end

class CartesianCoordinate
  attr_accessor :x, :y

  def initialize(*args)
    @x,@y=args
  end

  def serialize() {x:@x,y:@y} end
  def inspect() serialize.to_s end
  def to_s() serialize.to_s end
end

class PolarCoordinate
  attr_accessor :r, :theta

  def initialize(*args)
    @r,@theta=args
  end

  def serialize() {r:@r,theta:@theta} end
  def inspect() serialize.to_s end
  def to_s() serialize.to_s end

  def x
  end
  def y
  end
end

def tick args
  args.state.turtle ||= Turtle.new args
  #args.grid.origin_center!
  args.state.turtle.tick
end
