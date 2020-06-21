$gtk.reset

class PhaseFX
  #############################################################################
  # setup
  
  def initialize args
    @args = args
  end

  def serialize
    {}
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
  end

  #############################################################################
  # handle the game logic

  def logic
  end

  #############################################################################
  # draw stuff
 
  def render
    render_something
  end
   
  def render_something
    @args.outputs.labels << [100, 100, "@", 255, 0, 0]
  end


  #############################################################################
  # game loop

  def tick
    input
    logic
    render
  end

end

###############################################################################
# main

def tick args
  args.state.game ||= PhaseFX.new args
  args.state.game.tick

end
