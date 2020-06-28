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
    particle.next_position = particle.position
    particle.next_velocity = particle.velocity
    forces.each do |force| 
      #puts "#{force.x}/#{particle.mass}, #{force.y}/#{particle.mass} = "
      #puts force.x/particle.mass
      #puts force.y/particle.mass
      if (!force.x.nil? && !force.y.nil?) then
        acceleration = Vector.new(force.x/particle.mass,force.y/particle.mass)
      else
        $gtk.log_error("unexpected nil; particle: #{particle.to_s} force: #{force.to_s}")
        $gtk.pause!
        acceleration = Vector.new(0,0)
      end
      particle.next_velocity.x = particle.next_velocity.x + acceleration.x * dt
      particle.next_velocity.y = particle.next_velocity.y + acceleration.y * dt
      particle.next_position.x = particle.next_position.x + particle.next_velocity.x * dt
      particle.next_position.y = particle.next_position.y + particle.next_velocity.y * dt
    end
  end

end
