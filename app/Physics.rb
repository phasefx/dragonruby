class Vector < Struct.new(:x, :y)
end

class Particle < Struct.new(:position, :next_position, :velocity, :next_velocity, :mass)
end

module Physics

  def calculate_g_force particle
    Vector.new(0, (particle.mass * -9.81))
  end

  def calculate_next_vectors particle, forces
    dt = 0.02
    particle.next_position = particle.position
    particle.next_velocity = particle.velocity
    forces.each do |force| 
      #puts "#{force.x}/#{particle.mass}, #{force.y}/#{particle.mass} = "
      #puts force.x/particle.mass
      #puts force.y/particle.mass
      acceleration = Vector.new(force.x/particle.mass,force.y/particle.mass)
      particle.next_velocity.x = particle.next_velocity.x + acceleration.x * dt
      particle.next_velocity.y = particle.next_velocity.y + acceleration.y * dt
      particle.next_position.x = particle.next_position.x + particle.next_velocity.x * dt
      particle.next_position.y = particle.next_position.y + particle.next_velocity.y * dt
    end
  end

end
