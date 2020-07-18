class Turtle
  def initialize args
    @args = args
    @args.state[:pen_down?] = true
    @args.state.angle = 90
    @args.state.move = 0
    # bottomleft as origin, so put in middle
    @args.state.coord = CartesianCoordinate.new @args.grid.rect[2].half, @args.grid.rect[3].half
    @args.render_target(:turtle).lines << [
      [ 0, 1, 20, 1, 0, 0, 0 ],
      [ 0, 1, 10, 20, 0, 0, 0 ],
      [ 10, 20, 20, 1, 0, 0, 0 ],
      [ 10, 20, 10, 1, 0, 0, 0 ]
    ]
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
      angle: @args.state.angle-90,
      path: :turtle,
      source_x: 0,
      source_y: 0,
      source_w: 20,
      source_h: 20
    }
  end

  def tick
    # bottomleft as origin
    @args.outputs.labels << [
      @args.grid.rect[0],
      @args.grid.rect[3],
      "Turtle (#{@args.state.coord.x},#{@args.state.coord.y}) Angle: #{@args.state.angle} Pen: #{@args.state[:pen_down?] ? 'Down' : 'Up'}"
    ]
    render_turtle
    if @args.inputs.keyboard.key_down.left then
      lt 45
    end
    if @args.inputs.keyboard.key_down.right then
      rt 45
    end
    if @args.inputs.keyboard.key_down.up then
      fd 50
    end
    if @args.inputs.keyboard.key_down.down then
      bk 50
    end
    if @args.inputs.keyboard.key_down.space then
      pt
    end
    if @args.state.angle > 360 then
      @args.state.angle -= 360
    end
    if @args.state.angle < 0 then
      @args.state.angle += 360
    end
    if @args.state.move != 0 then
      offset = PolarCoordinate.new @args.state.move, @args.state.angle * Math::PI / 180 
      new_coord = CartesianCoordinate.new @args.state.coord.x + offset.x, @args.state.coord.y + offset.y
      @args.outputs.static_lines << [ @args.state.coord.x, @args.state.coord.y, new_coord.x, new_coord.y, 0, 0, 0 ] if @args.state[:pen_down?]
      @args.state.coord = new_coord
      @args.state.move = 0
    end
    if @tree then
      @fiber.resume if @fiber.alive?
    end
    if @args.inputs.keyboard.key_down.t then
      go_tree if !@tree
      @tree = true
    end
  end

  def go_tree
    @fiber = Fiber.new do
      tree 150
      @tree = false
    end
  end

  def tree size
    if size < 5 then
      @args.state.move = size ; Fiber.yield
      @args.state.move = -size ; Fiber.yield
    else
      @args.state.move = size / 3 ; Fiber.yield
      @args.state.angle += 30 ; Fiber.yield
      tree size*2/3 ; Fiber.yield
      @args.state.angle -= 30 ; # angle + move (in that order) may be paired together
      @args.state.move = size/6 ; Fiber.yield
      @args.state.angle -= 25 ; Fiber.yield
      tree size/2 ; Fiber.yield
      @args.state.angle += 25 ;
      @args.state.move = size/3 ; Fiber.yield
      @args.state.angle -= 25 ; Fiber.yield
      tree size/2 ; Fiber.yield
      @args.state.angle += 25 ;
      @args.state.move = size/6 ; Fiber.yield
      @args.state.move = -size ; Fiber.yield
    end
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
    @r * Math.cos(@theta)
  end
  def y
    @r * Math.sin(@theta)
  end
end

def fd r
  $args.state.move = r
end
alias f fd
alias fwd fd
alias forward fd

def bk r
  $args.state.move = -r
end
alias b bk
alias back bk

def rt theta
  $args.state.angle -= theta
end
alias r rt
alias right rt

def lt theta
  $args.state.angle += theta
end
alias l lt
alias left lt

def pu
  $args.state[:pen_down?] = false
end

def pd
  $args.state[:pen_down?] = true
end

def pt
  $args.state[:pen_down?] = ! $args.state[:pen_down?]
end

def pen args
  if args == 'up' then
    pu
  elsif args == 'down' then
    pd
  end
end

def cs
  $args.outputs.static_lines.clear
end
alias cls cs

def home
    $args.state.coord = CartesianCoordinate.new $args.grid.rect[2].half, $args.grid.rect[3].half
end


def tick args
  args.state.turtle ||= Turtle.new args
  args.state.turtle.tick
end
