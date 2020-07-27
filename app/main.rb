require 'geo3d/version.rb'
require 'geo3d/utils.rb'
require 'geo3d/vector.rb'
require 'geo3d/matrix.rb'
require 'geo3d/quaternion.rb'
require 'geo3d/plane.rb'
require 'geo3d/triangle.rb'

class Game

  attr :gx, :gy, :a, :b, :pa, :pb, :projection_matrix, :pm_fovy, :pm_aspect, :pm_left, :pm_right, :pm_bottom, :pm_top, :pm_zn, :pm_zf, :view_matrix, :vm_eye_position, :vm_look_at_position, :vm_up_direction

  def initialize args
    @gtk_args = args
    @gtk_grid = args.grid
    @gtk_outputs = args.outputs

    @gtk_args.grid.origin_center!

    @grid_half_width = @gtk_args.grid.w_half
    @grid_half_height = @gtk_args.grid.h_half

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

  def gx x
    x*@grid_half_width
  end

  def gy y
    y*@grid_half_height
  end

  def xg x
    @grid_half_width/x
  end

  def yg y
    @grid_half_height/y
  end

  def init_geometry

    # model space -> transformation -> world space
    # active space -> transformation matrix (translation, scale, rotation) -> active space
    # matrix multiplication is not commutative
    # view/camera space, projection matrix
    # model space -> transformation -> world space -> view matrix -> view space -> projection matrix -> projection space
    # orthographic and perspective projections
    # [View To Projection]x[World To View]x[Model to World]=[ModelViewProjectionMatrix]

    @a = Geo3d::Vector.point 1, 0, 1
    @b = Geo3d::Vector.point 0, 1, 1

    @vm_eye_position = Geo3d::Vector.point 0, 0, 0
    @vm_look_at_position = Geo3d::Vector.point 0, 0, 1
    @vm_up_direction = Geo3d::Vector.direction 0, 1, 0
    @view_matrix = Geo3d::Matrix.look_at_rh @vm_eye_position, @vm_look_at_position, @vm_up_direction

    @pm_fovy = 90
    @pm_aspect = @gtk_grid.rect.h/@gtk_grid.rect.w
    @pm_zn = -1
    @pm_zf = 1
    @pm_left = -1
    @pm_right = 1
    @pm_bottom = -1
    @pm_top = 1
    @projection_matrix = Geo3d::Matrix.glu_perspective_degrees @pm_fovy, @pm_aspect, @pm_zn, @pm_zf
    #@projection_matrix = Geo3d::Matrix.gl_ortho @pm_left, @pm_right, @pm_bottom, @pm_top, @pm_zn, @pm_zf

    @pa = @view_matrix * @projection_matrix * @a
    @pb = @view_matrix * @projection_matrix * @b
    puts "@a = #{@a}"
    puts "@vm * @pm * @a = #{@pa}"
    puts "grid x,y = #{gx(@pa.x/@pa.w)},#{gy(@pa.y/@pa.w)}" 
    puts "@b = #{@b}"
    puts "@vm * @pm * @b = #{@pb}"
    puts "grid x,y = #{gx(@pb.x/@pa.w)},#{gy(@pb.y/@pa.w)}" 

  end

  def tick
    @gtk_outputs.lines << [ gx(@a.x), gy(@a.y), gx(@b.x), gy(@b.y), 255, 0, 0 ]
    @gtk_outputs.lines << [ gx(@pa.x), gy(@pa.y), gx(@pb.x), gy(@pb.y), 0, 0, 255 ]
  end

end # of class Game

def tick args
  args.state.game ||= Game.new args
  args.state.game.tick
end # of def tick


