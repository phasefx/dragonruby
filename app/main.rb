require 'geo3d/version.rb'
require 'geo3d/utils.rb'
require 'geo3d/vector.rb'
require 'geo3d/matrix.rb'
require 'geo3d/quaternion.rb'
require 'geo3d/plane.rb'
require 'geo3d/triangle.rb'

class Game
  attr :projection_matrix, :center_matrix, :scale_matrix, :p1, :pp1

  def initialize args
    @gtk_args = args
    @gtk_grid = args.grid

    @gtk_args.grid.origin_center!

    def perspective

      @projection = :perspective

      l = -1
      r = 1
      b = -1
      t = 1
      zn = -1
      zf = 1

      @projection_matrix = Geo3d::Matrix.gl_frustum l, r, b, t, zn, zf

      mid_x = (l + r) * 0.5
      mid_y = (b + t)  * 0.5

      @center_matrix = Geo3d::Matrix.identity
      @center_matrix._14 = -mid_x
      @center_matrix._24 = -mid_y

      @perspective_matrix = Geo3d::Matrix.identity
      @perspective_matrix._11 = zn
      @perspective_matrix._22 = zn
      @perspective_matrix._43 = -1

      scale_x = 2.0 / (r - l)
      scale_y = 2.0 / (t - b)

      @scale_matrix = Geo3d::Matrix.identity
      @scale_matrix._11 = scale_x
      @scale_matrix._22 = scale_y

      c1 = 2*zf*zn / (zn - zf)
      c2 = (zf + zn) / (zf - zn)

      @depth_matrix = Geo3d::Matrix.identity
      @depth_matrix._33 = -c2
      @depth_matrix._34 = -1
      @depth_matrix._43 = c1
      @depth_matrix._44 = 0

      @convert_matrix = Geo3d::Matrix.identity
      # depth_matrix handled this for us

    end

    def orthographic

      @projection = :orthographic

      l = -1
      r = 1
      b = -1
      t = 1
      zn = -1
      zf = 1

      @projection_matrix = Geo3d::Matrix.gl_ortho l, r, b, t, zn, zf

      mid_x = (l + r) / 2
      mid_y = (b + t) / 2
      mid_z = (-zn + -zf) / 2

      @center_matrix = Geo3d::Matrix.identity
      @center_matrix._14 = -mid_x
      @center_matrix._24 = -mid_y
      @center_matrix._34 = -mid_z

      scale_x = 2.0 / (r - l)
      scale_y = 2.0 / (t - b)
      scale_z = 2.0 / (zf - zn)

      @scale_matrix = Geo3d::Matrix.identity
      @scale_matrix._11 = scale_x
      @scale_matrix._22 = scale_y
      @scale_matrix._33 = scale_z

      @depth_matrix = Geo3d::Matrix.identity
      # don't need this for ortho
      
      @convert_matrix = Geo3d::Matrix.identity
      @convert_matrix._33 = -1

    end

    #orthographic
    perspective

    @p1 = Geo3d::Vector.point 0.5, 0.5, 0.5
    case @projection
    when :orthographic then @pp1 = @projection_matrix * @convert_matrix * @scale_matrix * @center_matrix * @p1
    when :perspective then @pp1 = @projection_matrix * @scale_matrix * @perspective_matrix * @depth_matrix * @center_matrix * @p1
    end
  end
end

def tick args
  args.state.game ||= Game.new args
end

