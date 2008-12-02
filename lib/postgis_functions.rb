# #
#
# PostGIS Adapter - http://github.com/nofxx/postgis_adapter
#
#
#
# Links:
#
# PostGis Manual -  http://postgis.refractions.net/documentation/manual-svn/ch07.html
# Earth Spheroid - http://en.wikipedia.org/wiki/Figure_of_the_Earth
#
#
module PostgisFunctions

  # Defaul Earth Spheroid
  #
  #EARTH_SPHEROID = "'SPHEROID[\"GRS-80\",6378137,298.257222101]'"
  EARTH_SPHEROID = "'SPHEROID[\"IERS_2003\",6378136.6,298.25642]'"

  # Construct the postgis sql query
  # TODO: ST_Transform() ?? # Convert between distances. Implement this?
  #
  # Area return in square feet
  # Distance/DWithin/Length/Perimeter —  in projected units.
  # DistanceSphere/Spheroid —  in meters.
  #
  #
  def construct_geometric_sql(type,geoms,options)

    tables = geoms.map do |t| {
      :class => t.class.to_s.downcase.pluralize,
      :uid =>  unique_identifier,
      :id => t[:id] }
    end

    fields = tables.map { |f| f[:uid] + ".geom" }          # W1.geom
    froms = tables.map { |f| "#{f[:class]} #{f[:uid]}"}    # streets W1
    wheres = tables.map { |f| "#{f[:uid]}.id = #{f[:id]}"} # W1.id = 5

    # BBox =>  SELECT (A <> B)
    # Data =>  SELECT Fun(A,B)
    unless type == :bbox
      opcode = type.to_s
      #use all commands in lowcase form
      #opcode = opcode.camelize unless opcode =~ /spher|max|npoints/
      opcode = "ST_#{opcode}" unless opcode =~ /th3d|pesinter/
      s_join = ","
      fields << options if options
    else
      opcode = nil
      s_join = " #{options} "
    end

    sql =   "SELECT #{opcode}(#{fields.join(s_join)}) FROM #{froms.join(",")} "
    sql <<  "WHERE #{wheres.join(" AND ")}" if wheres
    #p sql; sql
  end

  # Execute the query, we may receive:
  #
  # "t" or "f" for boolean queries
  # BIGHASH    for geometries
  # Rescue     a float
  #
  def execute_geometrical_calculation(operation, subject, options) #:nodoc:
    value = connection.select_value(construct_geometric_sql(operation, subject, options))
    if value =~ /^\D/
      {"f" => false, "t" => true}[value]
    else
      GeoRuby::SimpleFeatures::Geometry.from_hex_ewkb(value) rescue value.to_f
    end
  end

  def calculate(operation, subject, options = nil)
    subject = [subject] unless subject.respond_to?(:map)
    return execute_geometrical_calculation(operation, subject, options)
  end

  # Get a unique ID for tables
  def unique_identifier
    @u_id ||= "W1"
    @u_id = @u_id.succ
  end

  # #
  #
  # COMMON GEOMETRICAL FUNCTIONS
  #
  #
  #
  def spatially_equal?(other)
    calculate(:equals, [self, other])
  end

  def envelope;    calculate(:envelope, self);  end
  def centroid;    calculate(:centroid, self);  end
  def boundary;    calculate(:boundary, self);  end

  # Distance to using cartesian formula
  def distance_to(other, unit=nil)
    dis = calculate(:distance, [self, other])
    return dis unless unit
    distance_convert(dis, unit, true)
  end

  def within? other
    calculate(:within, [self, other])
  end

  def contains? other
    calculate(:contains, [self, other])
  end

  def inside? other
    calculate(:coveredby, [self, other])
  end
  def outside? other;    !inside? other;  end

  def dimension
    calculate(:dimension, self).to_i
  end

  def simplify(tolerance=1)
    calculate(:simplify, self, tolerance)
  end

  def simplify_preserve_topology(tolerance=1)
    calculate(:simplifypreservetopology, self, tolerance)
  end

  def envelopes_intersect? other
     calculate(:se_envelopesintersect, [self, other])
  end

  def intersection other
    calculate(:intersection, [self, other])
  end

  def azimuth other
    #TODO: return if not point/point
    calculate(:azimuth, [self, other])
  end

  ###
  ##
  #
  # BBox
  #
  # These operators utilize indexes. They compare
  # bounding boxes of 2 geometries
  #
  #
  #  A.bbox(">>", B)
  #
  #   A &< B (A overlaps or is to the left of B)
  #   A &> B (A overlaps or is to the right of B)
  #   A << B (A is strictly to the left of B)
  #   A >> B (A is strictly to the right of B)
  #   A &<| B (A overlaps B or is below B)
  #   A |&> B (A overlaps or is above B)
  #   A <<| B (A strictly below B)
  #   A |>> B (A strictly above B)
  #   A = B (A bbox same as B bbox)
  #   A @ B (A completely contained by B)
  #   A ~ B (A completely contains B)
  #   A && B (A and B bboxes interact)
  #   A ~= B - true if A and B geometries are binary equal?
  #
  def bbox(operator, other)
    calculate(:bbox, [self, other], operator)
  end

  def completely_contained_by? other
    bbox("@", other)
  end

  def completely_contains? other
    bbox("~", other)
  end

  def overlaps_or_above? other
    bbox("|&>", other)
  end

  def overlaps_or_below? other
    bbox("&<|", other)
  end

  def overlaps_or_left_of? other
    bbox("&<", other)
  end

  def overlaps_or_right_of? other
    bbox("&>", other)
  end

  def strictly_above? other
    bbox("|>>", other)
  end

  def strictly_below? other
    bbox("<<|", other)
  end

  def strictly_left_of? other
    bbox("<<", other)
  end

  def strictly_right_of? other
    bbox(">>", other)
  end

  def interacts_with? other
    bbox("&&", other)
  end

  def binary_equal? other
    bbox("~=", other)
  end

  def same_as? other
    bbox("=", other)
  end

  ####
  ###
  ##
  #
  # POINT
  #
  #
  module PointFunctions
    def d_within?(other,margin=0.5)
      calculate(:dwithin, [self, other], margin)
    end
    alias_method "in_bounds?", "d_within?"

    # Return a float from 0.0 to 1.0
    def where_on_line line
      calculate(:line_locate_point, [line, self])
    end

    # Distance to using sphere (Haversine?) formula
    def distance_sphere_to(other)
      dis = calculate(:distance_sphere, [self, other])
    end
    alias_method :distance_spherical_to, :distance_sphere_to

    # Distance to using a spheroid
    # Slower then sphere or length, but more precise.
    def distance_spheroid_to(other, spheroid = EARTH_SPHEROID)
      calculate(:distance_spheroid, [self, other], spheroid)
    end

    # New stuff:
    # ST_point_inside_circle(geometry, float, float, float)
    #  point_inside_circle(<geometry>,<circle_center_x>,<circle_center_y>,<radius>).
    # Returns the true if the geometry is a point and is inside the circle.
    def inside_circle?(x,y,r)
      calculate(:point_inside_circle, self, [x,y,r])
    end

  end

  ####
  ###
  ##
  #
  # LINESTRING
  #
  #
  #
  module LineStringFunctions

    # Returns length using cartesian formula.
    def length
      dis = calculate(:length, self)
    end

    def length_3d
      dis = calculate(:length3d, self)
    end

    # Returns length using spheroid formula.
    # Arguments are (unit, spheroid)
    def length_spheroid(spheroid = EARTH_SPHEROID)
      dis = calculate(:length_spheroid, self, spheroid)
    end

    # Return the number of points of the geometry.
    # PostGis ST_NumPoints does not work as nov/08
    def num_points;     calculate(:npoints, self).to_i;    end

    # Return the first and last points.
    def start_point;    calculate(:startpoint, self);    end
    def end_point;      calculate(:endpoint, self);    end

    def intersects? other
      calculate(:intersects, [self, other])
    end

    def crosses? other
      calculate(:crosses, [self, other])
    end

    def touches? other
      calculate(:touches, [self, other])
    end

    # Locate a point on the line, return a float from 0 to 1
    def locate_point point
      calculate(:line_locate_point, [self, point])
    end

    #Not implemented in postgis
    # ST_max_distance Returns the largest distance between two line strings.
    #def max_distance other
    #  calculate(:max_distance, [self, other])
    #end
  end

  ###
  ##
  #
  # Polygon
  #
  #
  module PolygonFunctions

    def area
      calculate(:area, self)
    end

    def perimeter
      calculate(:perimeter, self)
    end

    def perimeter3d
      calculate(:perimeter3d, self)
    end

    def closed?
      calculate(:isclosed, self)
    end

    def overlaps? other
      calculate(:overlaps, [self, other])
    end

    def covers? other
      calculate(:covers, [self, other])
    end

    def touches? other
      calculate(:touches, [self, other])
    end

    def disjoint? other
      calculate(:disjoint, [self, other])
    end
  end

  ###
  ##
  #
  # Class Methods
  #
  # Falling back to AR here.
  #
  # TODO: ewkb or ewkt?
  #
  module ClassMethods

    def closest_to(p, srid=4326)
      find(:first, :order => "ST_Distance(geom, GeomFromText('POINT(#{p.x} #{p.y})', #{srid}))" )
    end

    def close_to(p, srid=4326)
      find(:all, :order => "ST_Distance(geom, GeomFromText('POINT(#{p.x} #{p.y})', #{srid}))" )
    end

    def by_size sort='asc'
      find(:all, :order => "ST_length(geom) #{sort}" )
    end

    def longest
      find(:first, :order => "ST_length(geom) DESC")
    end

    def contains(p, srid=4326)
      find(:all, :conditions => ["ST_Contains(geom, GeomFromText('POINT(#{p.x} #{p.y})', #{srid}))"])
    end

    def contain(p, srid=4326)
      find(:first, :conditions => ["ST_Contains(geom, GeomFromText('POINT(#{p.x} #{p.y})', #{srid}))"])
    end

    def by_area sort='asc'
      find(:all, :order => "ST_Area(geom) #{sort}" )
    end

    def by_perimeter sort='asc'
      find(:all, :order => "ST_Perimeter(geom) #{sort}" )
    end

    def all_within(other, margin=1)
#      find(:all, :conditions => "ST_DWithin(geom, ST_GeomFromEWKB(E'#{other.as_ewkt}'), #{margin})")
      find(:all, :conditions => "ST_DWithin(geom, ST_GeomFromEWKT(E'#{other.as_hex_ewkb}'), #{margin})")
    end

    def by_boundaries sort='asc'
      find(:all, :order => "ST_Boundary(geom) #{sort}" )
    end

  end
end


  #
  #x SE_LocateAlong
  #x SE_LocateBetween
  #x ST_line_interpolate_point(linestring, location)
  #x ST_line_substring(linestring, start, end)
  #x ST_line_locate_point(LineString, Point)   Returns a float between 0 and 1 representing the location of the closest point on LineString to the given Point, as a fraction of total 2d line length.
  #x ST_locate_along_measure(geometry, float8)   Return a derived geometry collection value with elements that match the specified measure. Polygonal elements are not supported.
  #x ST_locate_between_measures(geometry, float8, float8)
  #
  #x ST_Polygonize(geometry set)
  #x ST_SnapToGrid(geometry, geometry, sizeX, sizeY, sizeZ, sizeM)
  # ST_X , ST_Y, SE_M, SE_Z, SE_IsMeasured has_m?

  #x ST_Relate(geometry, geometry, intersectionPatternMatrix)
  #x ST_Disjoint(geometry, geometry)
  #x ST_Overlaps


# POINT(0 0)
# LINESTRING(0 0,1 1,1 2)
# POLYGON((0 0,4 0,4 4,0 4,0 0),(1 1, 2 1, 2 2, 1 2,1 1))
# MULTIPOINT(0 0,1 2)
# MULTILINESTRING((0 0,1 1,1 2),(2 3,3 2,5 4))
# MULTIPOLYGON(((0 0,4 0,4 4,0 4,0 0),(1 1,2 1,2 2,1 2,1 1)), ..)
# GEOMETRYCOLLECTION(POINT(2 3),LINESTRING((2 3,3 4)))

#
#Accessors
#ST_Dimension
#ST_Dump
#ST_EndPoint
#ST_Envelope
#ST_ExteriorRing
#ST_GeometryN
#ST_GeometryType
#ST_InteriorRingN
#ST_IsClosed
#ST_IsEmpty
#ST_IsRing
#ST_IsSimple
#ST_IsValid
#ST_mem_size
#ST_M
#ST_NumGeometries
#ST_NumInteriorRings
#ST_NumPoints
#ST_npoints
#ST_PointN
#ST_SetSRID
#ST_StartPoint
#ST_Summary1
#ST_X
#ST_XMin,ST_XMax
#ST_Y
#YMin,YMax
#ST_Z
#ZMin,ZMax

#OUTPUT

#ST_AsBinary
#ST_AsText
#ST_AsEWKB
#ST_AsEWKT
#ST_AsHEXEWKB
#ST_AsGML
#ST_AsKML
#ST_AsSVG
#  def distance_convert(value, unit, from = nil)
#    factor = case unit
#    when :km, :kilo     then  1
#    when :miles,:mile   then  0.62137119
#    when :cm, :cent     then  0.1
#    when :nmi, :nmile   then  0.5399568
#    end
#    factor *= 1e3 if from
#    value * factor
#  end
