require 'geo3d/version.rb'
require 'geo3d/utils.rb'
require 'geo3d/vector.rb'
require 'geo3d/matrix.rb'
require 'geo3d/quaternion.rb'
require 'geo3d/plane.rb'
require 'geo3d/triangle.rb'

TEXT_HEIGHT = $gtk.calcstringbox("H")[1]
KEY_HELD_DELAY = 30 # ticks

class Game

  attr :gx, :gy, :r1, :r2, :pr1, :pr2, :projection_matrix, :pm_fovy, :pm_aspect, :pm_left, :pm_right, :pm_bottom, :pm_top, :pm_zn, :pm_zf, :view_matrix, :vm_eye_position, :vm_look_at_position, :vm_up_direction

  def initialize args
    @gtk_args = args
    @gtk_grid = args.grid
    @gtk_outputs = args.outputs
    @gtk_inputs = args.inputs
    @gtk_kb = args.inputs.keyboard
    @gtk_state = args.state

    @gtk_grid.origin_center!

    init_geometry
  end

  def serialize
    {
      :view_matrix => @view_matrix,
      :vm_eye_position => @vm_eye_position,
      :vm_look_at_position => @vm_look_at_position,
      :vm_up_direction => @vm_up_direction,
      :projection_matrix => @projection_matrix,
      :pm_fovy => @pm_fovy,
      :pm_aspect => @pm_aspect,
      :pm_left => @pm_left,
      :pm_right => @pm_right,
      :pm_bottom => @pm_bottom,
      :pm_top => @pm_top,
      :pm_zn => @pm_zn,
      :pm_zf => @pm_zf,
      :a => @a,
      :b => @b,
      :pa => @pa,
      :pb => @pb
    }
  end

  def inspect
    serialize.to_s
  end

  def to_s
    serialize.to_s
  end

  def print
    serialize.each_with_index do |v,k|
      puts "#{k} => #{v}"
    end
    nil
  end

  def wrap v, lb, ub
    lb,ub = ub,lb if lb > ub
    return ub if v < lb
    return lb if v > ub
    v
  end

  def bound v, lb, ub
    lb,ub = ub,lb if lb > ub
    return lb if v < lb
    return ub if v > ub
    v
  end

  def unit_bound v
    bound v, -1, 1
  end

  def gx x
    x*@gtk_args.grid.w_half
  end

  def gy y
    y*@gtk_args.grid.h_half
  end

  def xg x
    @gtk_args.grid.w_half/x
  end

  def yg y
    @gtk_args.grid.h_half/y
  end

  def init_geometry

    # model space -> transformation -> world space
    # active space -> transformation matrix (translation, scale, rotation) -> active space
    # matrix multiplication is not commutative
    # view/camera space, projection matrix
    # model space -> transformation -> world space -> view matrix -> view space -> projection matrix -> projection space
    # orthographic and perspective projections
    # [View To Projection]x[World To View]x[Model to World]=[ModelViewProjectionMatrix]
    #
    # 1 -- 3
    # |    |
    # 0 -- 2

    @r1 = [ Geo3d::Vector.point(-0.1,-0.1,0.1), Geo3d::Vector.point(-0.1,0.1,0.1), Geo3d::Vector.point(0.1,-0.1,0.1), Geo3d::Vector.point(0.1,0.1,0.1) ]
    @r2 = [ Geo3d::Vector.point(-0.1,-0.1,-0.1), Geo3d::Vector.point(-0.1,0.1,-0.1), Geo3d::Vector.point(0.1,-0.1,-0.1), Geo3d::Vector.point(0.1,0.1,-0.1) ]

    @ux = Geo3d::Vector.point(1,0,0)
    @lx = Geo3d::Vector.point(-1,0,0)
    @uy = Geo3d::Vector.point(0,1,0)
    @ly = Geo3d::Vector.point(0,-1,0)
    @uz = Geo3d::Vector.point(0,0,1)
    @lz = Geo3d::Vector.point(0,0,-1)

    @model_x_angle = 0
    @model_y_angle = 0
    @model_z_angle = 0

    set_rotation_matrix

    @vm_eye_position = Geo3d::Vector.point 0.5, 0.5, -1
    @vm_look_at_position = Geo3d::Vector.point 0, 0, 1
    @vm_up_direction = Geo3d::Vector.direction 0, 1, 0

    set_view_matrix

    @pm_fovy = 90
    @pm_aspect = @gtk_grid.rect.h/@gtk_grid.rect.w
    @pm_zn = -1
    @pm_zf = 1
    @pm_left = -1
    @pm_right = 1
    @pm_bottom = -1
    @pm_top = 1

    @projection_type = :perspective
    set_projection
  end # of def init_geometry

  def set_rotation_matrix
    rotate_x = Geo3d::Matrix.rotation_x(Geo3d::Utils.to_radians(@model_x_angle))
    rotate_y = Geo3d::Matrix.rotation_y(Geo3d::Utils.to_radians(@model_y_angle))
    rotate_z = Geo3d::Matrix.rotation_z(Geo3d::Utils.to_radians(@model_z_angle))
    @rotation_matrix = rotate_x * rotate_y * rotate_z
  end

  def set_view_matrix
    @view_matrix = Geo3d::Matrix.look_at_rh @vm_eye_position, @vm_look_at_position, @vm_up_direction
  end

  def set_projection
    case @projection_type
    when :perspective then set_perspective_projection
    when :orthographic then set_orthographic_projection
    end
  end

  def set_perspective_projection
    @projection_matrix = Geo3d::Matrix.glu_perspective_degrees @pm_fovy, @pm_aspect, @pm_zn, @pm_zf
  end

  def set_orthographic_projection
    @projection_matrix = Geo3d::Matrix.gl_ortho @pm_left, @pm_right, @pm_bottom, @pm_top, @pm_zn, @pm_zf
  end

  def calculate_image
    @pr1 = @r1.map do |p|
      @rotation_matrix * @view_matrix * @projection_matrix * p
    end 
    @pr2 = @r2.map do |p|
      @rotation_matrix * @view_matrix * @projection_matrix * p
    end
    @pux = @view_matrix * @projection_matrix * @ux 
    @plx = @view_matrix * @projection_matrix * @lx 
    @puy = @view_matrix * @projection_matrix * @uy 
    @ply = @view_matrix * @projection_matrix * @ly 
    @puz = @view_matrix * @projection_matrix * @uz 
    @plz = @view_matrix * @projection_matrix * @lz 
  end

  def render

    # data
    @gtk_outputs.labels << [@gtk_grid.left, @gtk_grid.top - TEXT_HEIGHT *  0, "Camera@#{@vm_eye_position.to_a[0..2].to_s} Adjust with Arrows/PgUp/PgDn"]
    @gtk_outputs.labels << [@gtk_grid.left, @gtk_grid.top - TEXT_HEIGHT *  1, "Gazing@#{@vm_look_at_position.to_a[0..2].to_s} Adjust with WASD/Q/E"]
    @gtk_outputs.labels << [@gtk_grid.left, @gtk_grid.top - TEXT_HEIGHT *  2, "FOV #{@pm_fovy} Adjust with R/V"]
    @gtk_outputs.labels << [@gtk_grid.left, @gtk_grid.top - TEXT_HEIGHT *  3, "Projection: #{@projection_type}"]
    @gtk_outputs.labels << [@gtk_grid.left, @gtk_grid.top - TEXT_HEIGHT *  4, "O for Orthographic Projection"]
    @gtk_outputs.labels << [@gtk_grid.left, @gtk_grid.top - TEXT_HEIGHT *  5, "P for Perspective Projection"]
    @gtk_outputs.labels << [@gtk_grid.left, @gtk_grid.top - TEXT_HEIGHT *  6, "Space to Reset"]

    @gtk_outputs.labels << [@gtk_grid.left, @gtk_grid.top - TEXT_HEIGHT *  8, "Model Rotation (#{@model_x_angle},#{@model_y_angle},#{@model_z_angle})"]
    @gtk_outputs.labels << [@gtk_grid.left, @gtk_grid.top - TEXT_HEIGHT *  9, "Adjust x-axis with -/+"]
    @gtk_outputs.labels << [@gtk_grid.left, @gtk_grid.top - TEXT_HEIGHT * 10, "Adjust y-axis with 9/0"]
    @gtk_outputs.labels << [@gtk_grid.left, @gtk_grid.top - TEXT_HEIGHT * 11, "Adjust z-axis with 7/8"]

    # world axises
    @gtk_outputs.lines << [ gx(@pux.x), gy(@pux.y), gx(@plx.x), gy(@plx.y), 255, 0, 0 ]
    @gtk_outputs.lines << [ gx(@puy.x), gy(@puy.y), gx(@ply.x), gy(@ply.y), 0, 255, 0 ]
    @gtk_outputs.lines << [ gx(@puz.x), gy(@puz.y), gx(@plz.x), gy(@plz.y), 0, 0, 255 ]

    # far endcap
    @gtk_outputs.lines << [ gx(@pr1[0].x), gy(@pr1[0].y), gx(@pr1[1].x), gy(@pr1[1].y), 0, 0, 255 ]
    @gtk_outputs.lines << [ gx(@pr1[0].x), gy(@pr1[0].y), gx(@pr1[2].x), gy(@pr1[2].y), 0, 0, 255 ]
    @gtk_outputs.lines << [ gx(@pr1[3].x), gy(@pr1[3].y), gx(@pr1[1].x), gy(@pr1[1].y), 0, 0, 255 ]
    @gtk_outputs.lines << [ gx(@pr1[3].x), gy(@pr1[3].y), gx(@pr1[2].x), gy(@pr1[2].y), 0, 0, 255 ]

    # near endcap 
    @gtk_outputs.lines << [ gx(@pr2[0].x), gy(@pr2[0].y), gx(@pr2[1].x), gy(@pr2[1].y), 0, 255, 0 ]
    @gtk_outputs.lines << [ gx(@pr2[0].x), gy(@pr2[0].y), gx(@pr2[2].x), gy(@pr2[2].y), 0, 255, 0 ]
    @gtk_outputs.lines << [ gx(@pr2[3].x), gy(@pr2[3].y), gx(@pr2[1].x), gy(@pr2[1].y), 0, 255, 0 ]
    @gtk_outputs.lines << [ gx(@pr2[3].x), gy(@pr2[3].y), gx(@pr2[2].x), gy(@pr2[2].y), 0, 255, 0 ]

    # lines connecting the endcaps
    @gtk_outputs.lines << [ gx(@pr1[0].x), gy(@pr1[0].y), gx(@pr2[0].x), gy(@pr2[0].y), 255, 0, 0 ]
    @gtk_outputs.lines << [ gx(@pr1[1].x), gy(@pr1[1].y), gx(@pr2[1].x), gy(@pr2[1].y), 255, 0, 0 ]
    @gtk_outputs.lines << [ gx(@pr1[2].x), gy(@pr1[2].y), gx(@pr2[2].x), gy(@pr2[2].y), 255, 0, 0 ]
    @gtk_outputs.lines << [ gx(@pr1[3].x), gy(@pr1[3].y), gx(@pr2[3].x), gy(@pr2[3].y), 255, 0, 0 ]

  end # of def render

  def dec_fovy
    @pm_fovy = bound(@pm_fovy-1,1,180)
    @projection_type = :perspective
    set_projection
  end

  def inc_fovy
    @pm_fovy = bound(@pm_fovy+1,1,180)
    @projection_type = :perspective
    set_projection
  end

  def move_camera x, y, z
    @vm_eye_position.x = unit_bound( (@vm_eye_position.x + x).round(1) )
    @vm_eye_position.y = unit_bound( (@vm_eye_position.y + y).round(1) )
    @vm_eye_position.z = unit_bound( (@vm_eye_position.z + z).round(1) )
    set_view_matrix
  end

  def move_gaze x, y, z
    @vm_look_at_position.x = unit_bound( (@vm_look_at_position.x + x).round(1) )
    @vm_look_at_position.y = unit_bound( (@vm_look_at_position.y + y).round(1) )
    @vm_look_at_position.z = unit_bound( (@vm_look_at_position.z + z).round(1) )
    set_view_matrix
  end

  def rotate_model x, y, z
    @model_x_angle = wrap( @model_x_angle + x, 0, 359 )
    @model_y_angle = wrap( @model_y_angle + y, 0, 359 )
    @model_z_angle = wrap( @model_z_angle + z, 0, 359 )
    set_rotation_matrix
  end

  def input

    # reset
    if @gtk_kb.key_up.space
      init_geometry
    end

    # projection types
    if @gtk_kb.key_up.o
      @projection_type = :orthographic
      set_projection
    end
    if @gtk_kb.key_up.p
      @projection_type = :perspective
      set_projection
    end

    # fovy
    if @gtk_kb.key_down.r
      @kb_r_down_at = @gtk_state.tick_count
      dec_fovy
    end
    if @gtk_kb.key_held.r && @gtk_state.tick_count - @kb_r_down_at > KEY_HELD_DELAY
      dec_fovy
    end
    if @gtk_kb.key_down.f
      @kb_f_down_at = @gtk_state.tick_count
      inc_fovy
    end
    if @gtk_kb.key_held.f && @gtk_state.tick_count - @kb_f_down_at > KEY_HELD_DELAY
      inc_fovy
    end

    # camera

    if @gtk_kb.key_down.left
      @kb_left_down_at = @gtk_state.tick_count
      move_camera(-0.1, 0, 0)
    end
    if @gtk_kb.key_held.left && @gtk_state.tick_count - @kb_left_down_at > KEY_HELD_DELAY
      move_camera(-0.1, 0, 0)
    end
    if @gtk_kb.key_down.right
      @kb_right_down_at = @gtk_state.tick_count
      move_camera(0.1, 0, 0)
    end
    if @gtk_kb.key_held.right && @gtk_state.tick_count - @kb_right_down_at > KEY_HELD_DELAY
      move_camera(0.1, 0, 0)
    end
    if @gtk_kb.key_down.up
      @kb_up_down_at = @gtk_state.tick_count
      move_camera(0, 0.1, 0)
    end
    if @gtk_kb.key_held.up && @gtk_state.tick_count - @kb_up_down_at > KEY_HELD_DELAY
      move_camera(0, 0.1, 0)
    end
    if @gtk_kb.key_down.down
      @kb_down_down_at = @gtk_state.tick_count
      move_camera(0, -0.1, 0)
    end
    if @gtk_kb.key_held.down && @gtk_state.tick_count - @kb_down_down_at > KEY_HELD_DELAY
      move_camera(0, -0.1, 0)
    end
    if @gtk_kb.key_down.pageup
      @kb_pageup_down_at = @gtk_state.tick_count
      move_camera(0, 0, -0.1)
    end
    if @gtk_kb.key_held.pageup && @gtk_state.tick_count - @kb_pageup_down_at > KEY_HELD_DELAY
      move_camera(0, 0, -0.1)
    end
    if @gtk_kb.key_down.pagedown
      @kb_pagedown_down_at = @gtk_state.tick_count
      move_camera(0, 0, 0.1)
    end
    if @gtk_kb.key_held.pagedown && @gtk_state.tick_count - @kb_pagedown_down_at > KEY_HELD_DELAY
      move_camera(0, 0, 0.1)
    end

    # gaze
   
    if @gtk_kb.key_down.a
      @kb_a_down_at = @gtk_state.tick_count
      move_gaze(-0.1, 0, 0)
    end
    if @gtk_kb.key_held.a && @gtk_state.tick_count - @kb_a_down_at > KEY_HELD_DELAY
      move_gaze(-0.1, 0, 0)
    end
    if @gtk_kb.key_down.d
      @kb_d_down_at = @gtk_state.tick_count
      move_gaze(0.1, 0, 0)
    end
    if @gtk_kb.key_held.d && @gtk_state.tick_count - @kb_d_down_at > KEY_HELD_DELAY
      move_gaze(0.1, 0, 0)
    end
    if @gtk_kb.key_down.w
      @kb_w_down_at = @gtk_state.tick_count
      move_gaze(0, 0.1, 0)
    end
    if @gtk_kb.key_held.w && @gtk_state.tick_count - @kb_w_down_at > KEY_HELD_DELAY
      move_gaze(0, 0.1, 0)
    end
    if @gtk_kb.key_down.s
      @kb_s_down_at = @gtk_state.tick_count
      move_gaze(0, -0.1, 0)
    end
    if @gtk_kb.key_held.s && @gtk_state.tick_count - @kb_s_down_at > KEY_HELD_DELAY
      move_gaze(0, -0.1, 0)
    end
    if @gtk_kb.key_down.q
      @kb_q_down_at = @gtk_state.tick_count
      move_gaze(0, 0, -0.1)
    end
    if @gtk_kb.key_held.q && @gtk_state.tick_count - @kb_q_down_at > KEY_HELD_DELAY
      move_gaze(0, 0, -0.1)
    end
    if @gtk_kb.key_down.e
      @kb_e_down_at = @gtk_state.tick_count
      move_gaze(0, 0, 0.1)
    end
    if @gtk_kb.key_held.e && @gtk_state.tick_count - @kb_e_down_at > KEY_HELD_DELAY
      move_gaze(0, 0, 0.1)
    end

    # rotate model
    if @gtk_kb.key_down.hyphen
      @kb_hyphen_down_at = @gtk_state.tick_count
      rotate_model(-1, 0, 0)
    end
    if @gtk_kb.key_held.hyphen && @gtk_state.tick_count - @kb_hyphen_down_at > KEY_HELD_DELAY
      rotate_model(-1, 0, 0)
    end
    if @gtk_kb.key_down.equal_sign
      @kb_equal_sign_down_at = @gtk_state.tick_count
      rotate_model(1, 0, 0)
    end
    if @gtk_kb.key_held.equal_sign && @gtk_state.tick_count - @kb_equal_sign_down_at > KEY_HELD_DELAY
      rotate_model(1, 0, 0)
    end
    if @gtk_kb.key_down.nine
      @kb_nine_down_at = @gtk_state.tick_count
      rotate_model(0, -1, 0)
    end
    if @gtk_kb.key_held.nine && @gtk_state.tick_count - @kb_nine_down_at > KEY_HELD_DELAY
      rotate_model(0, -1, 0)
    end
    if @gtk_kb.key_down.zero
      @kb_zero_down_at = @gtk_state.tick_count
      rotate_model(0, 1, 0)
    end
    if @gtk_kb.key_held.zero && @gtk_state.tick_count - @kb_zero_down_at > KEY_HELD_DELAY
      rotate_model(0, 1, 0)
    end
    if @gtk_kb.key_down.seven
      @kb_seven_down_at = @gtk_state.tick_count
      rotate_model(0, 0, -1)
    end
    if @gtk_kb.key_held.seven && @gtk_state.tick_count - @kb_seven_down_at > KEY_HELD_DELAY
      rotate_model(0, 0, -1)
    end
    if @gtk_kb.key_down.eight
      @kb_eight_down_at = @gtk_state.tick_count
      rotate_model(0, 0, 1)
    end
    if @gtk_kb.key_held.eight && @gtk_state.tick_count - @kb_eight_down_at > KEY_HELD_DELAY
      rotate_model(0, 0, 1)
    end
  end

  def tick

    input
    calculate_image
    render

  end # of def tick

end # of class Game

def tick args
  args.state.game ||= Game.new args
  args.state.game.tick
end # of def tick


