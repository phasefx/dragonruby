class Vector
  attr_accessor :x, :y, :tag

  def initialize(*args)
    @x,@y,@tag=args
  end

  def serialize() {x:@x,y:@y} end
  def inspect() serialize.to_s end
  def to_s() serialize.to_s end
end

class Particle
  attr_accessor :position, :next_position, :velocity, :next_velocity, :mass

  def initialize(*args)
    @position,@next_position,@velocity,@next_velocity,@mass=args
  end

  def serialize()
    {
      position:@position,
      next_position:@next_position,
      velocity:@velocity,
      next_velocity:@next_velocity,
      mass:@mass
    }
  end
  def inspect() serialize.to_s end
  def to_s() serialize.to_s end
end

module Physics

  def calculate_g_force particle
    Vector.new(0, (particle.mass * -9.81), :gravity)
  end

  def calculate_next_vectors particle, forces
    dt = 0.2
    particle.next_position.x = particle.position.x
    particle.next_position.y = particle.position.y
    particle.next_velocity.x = particle.velocity.x
    particle.next_velocity.y = particle.velocity.y
    forces.each do |force| 
      assert !force.x.nil? && !force.y.nil?, "unexpected nil in force"
      acceleration = Vector.new(force.x/particle.mass,force.y/particle.mass)
      particle.next_velocity.x = particle.next_velocity.x + acceleration.x * dt
      particle.next_velocity.y = particle.next_velocity.y + acceleration.y * dt
    end
    particle.next_position.x = particle.next_position.x + particle.next_velocity.x * dt
    particle.next_position.y = particle.next_position.y + particle.next_velocity.y * dt
  end

end
