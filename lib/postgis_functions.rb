# #
#
# PostGIS Adapter - http://github.com/nofxx/postgis_adapter
#
#
#
# Hope you enjoy this software. Please post any bugs/suggestions to the lighthouse tracker:
# http://nofxx.lighthouseapp.com/projects/20712-postgisadapter
#
#
#
#
# Some Links:
#
# PostGis Manual -  http://postgis.refractions.net/documentation/manual-svn/ch07.html
# Earth Spheroid - http://en.wikipedia.org/wiki/Figure_of_the_Earth
#
#
#
module PostgisFunctions
  # EARTH_SPHEROID = "'SPHEROID[\"GRS-80\",6378137,298.257222101]'"

  EARTH_SPHEROID = "'SPHEROID[\"IERS_2003\",6378136.6,298.25642]'"

  def postgis_calculate(operation, subject, options = nil)
    subject = [subject] unless subject.respond_to?(:map)
    return execute_geometrical_calculation(operation, subject, options)
  end

  # #
  #
  # COMMON GEOMETRICAL FUNCTIONS
  #
  # The methods here can be used by all geoms.
  #

  #
  # True if the given geometries represent the same geometry.
  # Directionality is ignored.
  #
  # Returns TRUE if the given Geometries are "spatially equal".
  # Use this for a 'better' answer than '='. Note by spatially equal we
  # mean ST_Within(A,B) = true and ST_Within(B,A) = true and also mean ordering
  # of points can be different but represent the same geometry structure.
  # To verify the order of points is consistent, use ST_OrderingEquals
  # (it must be noted ST_OrderingEquals is a little more stringent than
  # simply verifying order of points are the same).
  #
  # This function will return false if either geometry is invalid even 
  # if they are binary equal.
  #
  # Returns Boolean ST_Equals(geometry A, geometry B);
  #
  def spatially_equal?(other)
    postgis_calculate(:equals, [self, other])
  end

  #
  # Returns the minimum bounding box for the supplied geometry, as a geometry.
  # The polygon is defined by the corner points of the bounding box
  # ((MINX, MINY), (MINX, MAXY), (MAXX, MAXY), (MAXX, MINY), (MINX, MINY)).
  # PostGIS will add a ZMIN/ZMAX coordinate as well/
  #
  # Degenerate cases (vertical lines, points) will return a geometry of
  # lower dimension than POLYGON, ie. POINT or LINESTRING.
  #
  # In PostGIS, the bounding box of a geometry is represented internally using
  # float4s instead of float8s that are used to store geometries. The bounding
  # box coordinates are floored, guarenteeing that the geometry is contained
  # entirely within its bounds. This has the advantage that a geometry's
  # bounding box is half the size as the minimum bounding rectangle,
  # which means significantly faster indexes and general performance.
  # But it also means that the bounding box is NOT the same as the minimum
  # bounding rectangle that bounds the geome.
  #
  # Returns GeometryCollection ST_Envelope(geometry g1);
  #
  def envelope
    postgis_calculate(:envelope, self)
  end

  #
  # Computes the geometric center of a geometry, or equivalently,
  # the center of mass of the geometry as a POINT. For [MULTI]POINTs, this is
  # computed as the arithmetric mean of the input coordinates.
  # For [MULTI]LINESTRINGs, this is computed as the weighted length of each
  # line segment. For [MULTI]POLYGONs, "weight" is thought in terms of area.
  # If an empty geometry is supplied, an empty GEOMETRYCOLLECTION is returned.
  # If NULL is supplied, NULL is returned.
  #
  # The centroid is equal to the centroid of the set of component Geometries of
  # highest dimension (since the lower-dimension geometries contribute zero
  # "weight" to the centroid).
  #
  # Computation will be more accurate if performed by the GEOS module (enabled at compile time).
  #
  # http://postgis.refractions.net/documentation/manual-svn/ST_Centroid.html
  #
  # Returns Geometry ST_Centroid(geometry g1);
  #
  def centroid
    postgis_calculate(:centroid, self)
  end
  
  #
  # Returns the closure of the combinatorial boundary of this Geometry. 
  # The combinatorial boundary is defined as described in section 3.12.3.2 of the
  # OGC SPEC. Because the result of this function is a closure, and hence topologically
  # closed, the resulting boundary can be represented using representational
  # geometry primitives as discussed in the OGC SPEC, section 3.12.2.
  #
  # Do not call with a GEOMETRYCOLLECTION as an argument.
  #
  # Performed by the GEOS module.
  #
  # Returns Geometry ST_Boundary(geometry geomA);
  #
  def boundary
    postgis_calculate(:boundary, self)
  end

  #
  # 2D minimum cartesian distance between two geometries in projected units.
  #
  # Returns Float ST_Distance(geometry g1, geometry g2);
  #
  def distance_to(other)
    postgis_calculate(:distance, [self, other])
  end
  
  #
  # True if geometry A is completely inside geometry B.
  #
  # For this function to make sense, the source geometries must both be of the same
  # coordinate projection, having the same SRID. It is a given that
  # if ST_Within(A,B) is true and ST_Within(B,A) is true, then the
  # two geometries are considered spatially equal.
  #
  # This function call will automatically include a bounding box comparison that will
  # make use of any indexes that are available on the geometries. To avoid index use,
  # use the function _ST_Within.
  #
  # Do not call with a GEOMETRYCOLLECTION as an argument
  # Do not use this function with invalid geometries. You will get unexpected results.
  #
  # Performed by the GEOS module.
  #
  # Returns Boolean ST_Within(geometry A, geometry B);
  #
  def within? other
    postgis_calculate(:within, [self, other])
  end

  #
  # True if geometry B is completely inside geometry A. 
  #
  # For this function to make sense, the source geometries must both be of the same 
  # coordinate projection, having the same SRID. 'contains?' is the inverse of 'within?'.
  #
  # So a.contains?(b) is like b.within?(a) except in the case of invalid
  # geometries where the result is always false regardless or not defined.
  #
  # Do not call with a GEOMETRYCOLLECTION as an argument
  # Do not use this function with invalid geometries. You will get unexpected results.
  #
  # Performed by the GEOS module
  #
  # Returns Boolean ST_Contains(geometry geomA, geometry geomB);
  #
  def contains? other
    postgis_calculate(:contains, [self, other])
  end
  
  #
  # True if no point in Geometry A is outside Geometry B
  #
  # This function call will automatically include a bounding box comparison that
  # will make use of any indexes that are available on the geometries. To avoid
  # index use, use the function _ST_CoveredBy.
  #
  # Do not call with a GEOMETRYCOLLECTION as an argument.
  # Do not use this function with invalid geometries. You will get unexpected results.
  #
  # Performed by the GEOS module.
  #
  # Aliased as 'inside?'
  #
  # Returns Boolean ST_CoveredBy(geometry geomA, geometry geomB);
  #
  def covered_by? other
    postgis_calculate(:coveredby, [self, other])
  end
  alias_method "inside?", "covered_by?"
  
  #
  # Eye-candy. See 'covered_by?'.
  #
  # Returns !(Boolean ST_CoveredBy(geometry geomA, geometry geomB);)
  #
  def outside? other
    !covered_by? other
  end

  #
  # True if the Geometries do not "spatially intersect" - if they
  # do not share any space together.
  #
  # Overlaps, Touches, Within all imply geometries are not spatially disjoint.
  # If any of the aforementioned returns true, then the geometries are not
  # spatially disjoint. Disjoint implies false for spatial intersection.
  #
  # Do not call with a GEOMETRYCOLLECTION as an argument.
  #
  # Returns boolean ST_Disjoint( geometry A , geometry B );
  #
  def disjoint? other
    postgis_calculate(:disjoint, [self, other])
  end

  #
  # How many dimensions the geom is made of (2, 3 or 4)
  #
  # Returns Integer  ST_Dimension(geom g1)
  #
  def dimension
    postgis_calculate(:dimension, self).to_i
  end

  #
  # Returns a "simplified" version of the given geometry using the Douglas-Peuker
  # algorithm. Will actually do something only with (multi)lines and (multi)polygons
  # but you can safely call it with any kind of geometry. Since simplification
  # occurs on a object-by-object basis you can also feed a GeometryCollection to this
  # function.
  #
  # Note that returned geometry might loose its simplicity (see 'is_simple?').
  # Topology may not be preserved and may result in invalid geometries.
  # Use 'simplify_preserve_topology' to preserve topology.
  #
  # Performed by the GEOS Module.
  #
  # Returns Geometry ST_Simplify(geometry geomA, float tolerance);
  #
  def simplify(tolerance=0.1)
    postgis_calculate(:simplify, self, tolerance)
  end
  #TODO:  #def simplify!

  #
  # Returns a "simplified" version of the given geometry using the Douglas-Peuker
  # algorithm. Will avoid creating derived geometries (polygons in particular) that
  # are invalid. Will actually do something only with (multi)lines and (multi)polygons
  # but you can safely call it with any kind of geometry. Since simplification occurs
  # on a object-by-object basis you can also feed a GeometryCollection to this function.
  #
  # Performed by the GEOS module. Requires GEOS 3.0.0+
  #
  # Returns Geometry ST_SimplifyPreserveTopology(geometry geomA, float tolerance);
  #
  def simplify_preserve_topology(tolerance=0.1)
    postgis_calculate(:simplifypreservetopology, self, tolerance)
  end

  #
  # True if Geometries "spatially intersect", share any portion of space.
  # False if they don't (they are Disjoint).
  # 
  # 'overlaps?', 'touches?', 'within?' all imply spatial intersection.
  # If any of the aforementioned returns true, then the geometries also
  # spatially intersect. 'disjoint?' implies false for spatial intersection.
  #
  # Returns Boolean ST_Intersects(geometry geomA, geometry geomB);
  #
  def intersects? other
    postgis_calculate(:intersects, [self, other])
  end

  #
  # True if a Geometry`s Envelope "spatially intersect", share any portion of space.
  #
  # It`s 'intersects?', for envelopes.
  #
  # Returns Boolean SE_EnvelopesIntersect(geometry geomA, geometry geomB);
  #
  def envelopes_intersect? other
     postgis_calculate(:se_envelopesintersect, [self, other])
  end

  #
  # Geometry that represents the point set intersection of the Geometries.
  # In other words - that portion of geometry A and geometry B that is shared between
  # the two geometries. If the geometries do not share any space (are disjoint),
  # then an empty geometry collection is returned.
  #
  # 'intersection' in conjunction with intersects? is very useful for clipping
  # geometries such as in bounding box, buffer, region queries where you only want
  # to return that portion of a geometry that sits in a country or region of interest.
  #
  # Do not call with a GEOMETRYCOLLECTION as an argument.
  # Performed by the GEOS module.
  #
  # Returns Geometry ST_Intersection(geometry geomA, geometry geomB);
  #
  def intersection other
    postgis_calculate(:intersection, [self, other])
  end

  #
  # True if the Geometries share space, are of the same dimension, but are
  # not completely contained by each other. They intersect, but one does not
  # completely contain another.
  #
  # Do not call with a GeometryCollection as an argument
  # This function call will automatically include a bounding box comparison that
  # will make use of any indexes that are available on the geometries. To avoid
  # index use, use the function _ST_Overlaps.
  #
  # Performed by the GEOS module.
  #
  # Returns Boolean ST_Overlaps(geometry A, geometry B);
  #
  def overlaps? other
    postgis_calculate(:overlaps, [self, other])
    rescue
    ActiveRecord::StatementInvalid
  end

  # True if the geometries have at least one point in common,
  # but their interiors do not intersect.
  #
  # If the only points in common between g1 and g2 lie in the union of the
  # boundaries of g1 and g2. The 'touches?' relation applies to all Area/Area,
  # Line/Line, Line/Area, Point/Area and Point/Line pairs of relationships,
  # but not to the Point/Point pair.
  #
  # Returns Boolean ST_Touches(geometry g1, geometry g2);
  #
  def touches? other
    postgis_calculate(:touches, [self, other])
  end

  #
  # The convex hull of a geometry represents the minimum closed geometry that
  # encloses all geometries within the set.
  #
  # It is usually used with MULTI and Geometry Collections. Although it is not
  # an aggregate - you can use it in conjunction with ST_Collect to get the convex
  # hull of a set of points. ST_ConvexHull(ST_Collect(somepointfield)).
  # It is often used to determine an affected area based on a set of point observations.
  #
  # Performed by the GEOS module.
  #
  # Returns Geometry ST_ConvexHull(geometry geomA);
  #
  def convex_hull
    postgis_calculate(:convexhull, self)
  end
  
  #
  # Returns true if this Geometry has no anomalous geometric points, such as
  # self intersection or self tangency.
  #
  # Returns boolean ST_IsSimple(geometry geomA);
  #
  def is_simple?
    postgis_calculate(:issimple, self)
  end
  alias_method "simple?", "is_simple?"


  # NEW
  #ST_OrderingEquals — Returns true if the given geometries represent the same geometry and points are in the same directional order.
  #boolean ST_OrderingEquals(g
  #  ST_PointOnSurface — Returns a POINT guaranteed to lie on the surface.
  #geometry ST_PointOnSurface(geometry g1);eometry A, geometry B);


  ###
  ##
  #
  # BBox
  #
  #
  
  #
  # These operators utilize indexes. They compare geometries by bounding boxes.
  #
  # You can use the literal forms or call directly using the 'bbox' method. eg.:
  #  
  #   @point.bbox(">>", @area)
  #   @point.bbox("|&>", @area)
  #
  #
  # Cheatsheet:
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
    postgis_calculate(:bbox, [self, other], operator)
  end

  #
  #  bbox literal method.
  #
  def completely_contained_by? other
    bbox("@", other)
  end

  #
  #  bbox literal method.
  #
  def completely_contains? other
    bbox("~", other)
  end

  #
  #  bbox literal method.
  #
  def overlaps_or_above? other
    bbox("|&>", other)
  end

  #
  #  bbox literal method.
  #
  def overlaps_or_below? other
    bbox("&<|", other)
  end

  #
  #  bbox literal method.
  #
  def overlaps_or_left_of? other
    bbox("&<", other)
  end

  #
  #  bbox literal method.
  #
  def overlaps_or_right_of? other
    bbox("&>", other)
  end

  #
  #  bbox literal method.
  #
  def strictly_above? other
    bbox("|>>", other)
  end

  #
  #  bbox literal method.
  #
  def strictly_below? other
    bbox("<<|", other)
  end

  #
  #  bbox literal method.
  #
  def strictly_left_of? other
    bbox("<<", other)
  end

  #
  #  bbox literal method.
  #
  def strictly_right_of? other
    bbox(">>", other)
  end

  #
  #  bbox literal method.
  #
  def interacts_with? other
    bbox("&&", other)
  end

  #
  #  bbox literal method.
  #
  def binary_equal? other
    bbox("~=", other)
  end

  #
  #  bbox literal method.
  #
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

    #
    # True if the geometries are within the specified distance of one another.
    # The distance is specified in units defined by the spatial reference system
    # of the geometries. For this function to make sense, the source geometries
    # must both be of the same coorindate projection, having the same SRID.
    #
    # Returns boolean ST_DWithin(geometry g1, geometry g2, double precision distance);
    #
    def d_within?(other, margin=0.1)
      postgis_calculate(:dwithin, [self, other], margin)
    end
    alias_method "in_bounds?", "d_within?"

    #
    # Returns a float between 0 and 1 representing the location of the closest point
    # on LineString to the given Point, as a fraction of total 2d line length.
    #
    # You can use the returned location to extract a Point (ST_Line_Interpolate_Point)
    # or a substring (ST_Line_Substring).
    #
    # This is useful for approximating numbers of addresses.
    #
    # Returns float (0 to 1) ST_Line_Locate_Point(geometry a_linestring, geometry a_point);
    #
    def where_on_line line
      postgis_calculate(:line_locate_point, [line, self])
    end

    #
    # Linear distance in meters between two lon/lat points.
    # Uses a spherical earth and radius of 6370986 meters.
    # Faster than 'distance_spheroid', but less accurate.
    #
    # Only implemented for points.
    #
    # Returns Float ST_Distance_Sphere(geometry pointlonlatA, geometry pointlonlatB);
    #
    def distance_sphere_to(other)
      dis = postgis_calculate(:distance_sphere, [self, other])
    end

    #
    # Calculates the distance on an ellipsoid. This is useful if the
    # coordinates of the geometry are in longitude/latitude and a length is
    # desired without reprojection. The ellipsoid is a separate database type and
    # can be constructed as follows:
    #
    # This is slower then 'distance_sphere_to', but more precise.
    #
    # SPHEROID[<NAME>,<SEMI-MAJOR AXIS>,<INVERSE FLATTENING>]
    #
    # Example:
    #   SPHEROID["GRS_1980",6378137,298.257222101]
    #
    # Defaults to:
    #
    #   SPHEROID["IERS_2003",6378136.6,298.25642]
    #
    # Returns ST_Distance_Spheroid(geometry geomA, geometry geomB, spheroid);
    #
    def distance_spheroid_to(other, spheroid = EARTH_SPHEROID)
      postgis_calculate(:distance_spheroid, [self, other], spheroid)
      rescue
        ActiveRecord::StatementInvalid
    end

    #
    # The azimuth of the segment defined by the given Point geometries,
    # or NULL if the two points are coincident. Return value is in radians.
    #
    # The Azimuth is mathematical concept defined as the angle, in this case
    # measured in radian, between a reference plane and a point.
    #
    # Returns Float ST_Azimuth(geometry pointA, geometry pointB);
    #
    def azimuth other
      #TODO: return if not point/point
      postgis_calculate(:azimuth, [self, other])
      rescue
        ActiveRecord::StatementInvalid
    end

    #
    # True if the geometry is a point and is inside the circle.
    #
    # Returns Boolean ST_point_inside_circle(geometry, float, float, float)
    #
    def inside_circle?(x,y,r)
      postgis_calculate(:point_inside_circle, self, [x,y,r])
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

    # Returns the 2D length of the geometry if it is a linestring, multilinestring,
    # ST_Curve, ST_MultiCurve. 0 is returned for areal geometries. For areal geometries
    # use 'perimeter'. Measurements are in the units of the spatial reference system
    # of the geometry.
    #
    # Returns Float
    #
    def length
      dis = postgis_calculate(:length, self)
    end

    # Returns the 3-dimensional or 2-dimensional length of the geometry if it is
    # a linestring or multi-linestring. For 2-d lines it will just return the 2-d
    # length (same as 'length')
    #
    # Returns Float
    #
    def length_3d
      dis = postgis_calculate(:length3d, self)
    end

    # Calculates the length of a geometry on an ellipsoid. This is useful if the
    # coordinates of the geometry are in longitude/latitude and a length is
    # desired without reprojection. The ellipsoid is a separate database type and
    # can be constructed as follows:
    #
    # SPHEROID[<NAME>,<SEMI-MAJOR AXIS>,<INVERSE FLATTENING>]
    #
    # Example:
    #   SPHEROID["GRS_1980",6378137,298.257222101]
    #
    # Defaults to:
    #
    #   SPHEROID["IERS_2003",6378136.6,298.25642]
    #
    # Returns Float
    #
    def length_spheroid(spheroid = EARTH_SPHEROID)
      dis = postgis_calculate(:length_spheroid, self, spheroid)
    end

    #float ST_Max_Distance(geometry g1, geometry g2);
    #Not implemented in postgis yet

    # Return the number of points of the geometry.
    # PostGis ST_NumPoints does not work as nov/08
    #
    # Returns Integer
    #
    def num_points
      postgis_calculate(:npoints, self).to_i
    end

    #
    # Returns geometry start point.
    #
    def start_point
      postgis_calculate(:startpoint, self)
    end

    #
    # Returns geometry last point.
    #
    def end_point
      postgis_calculate(:endpoint, self)
    end

    #
    # Takes two geometry objects and returns TRUE if their intersection
    # "spatially cross", that is, the geometries have some, but not all interior
    # points in common. The intersection of the interiors of the geometries must
    # not be the empty set and must have a dimensionality less than the the
    # maximum dimension of the two input geometries. Additionally, the
    # intersection of the two geometries must not equal either of the source
    # geometries. Otherwise, it returns FALSE.
    #
    #
    # Returns Boolean ST_Crosses(geometry g1, geometry g2);
    #
    def crosses? other
      postgis_calculate(:crosses, [self, other])
    end

    #
    # Returns a float between 0 and 1 representing the location of the closest point
    # on LineString to the given Point, as a fraction of total 2d line length.
    #
    # You can use the returned location to extract a Point (ST_Line_Interpolate_Point)
    # or a substring (ST_Line_Substring).
    #
    # This is useful for approximating numbers of addresses.
    #
    # Returns float (0 to 1) ST_Line_Locate_Point(geometry a_linestring, geometry a_point);
    #
    def locate_point point
      postgis_calculate(:line_locate_point, [self, point])
    end

    #
    # Returns a point interpolated along a line. First argument must be a LINESTRING.
    # Second argument is a float8 between 0 and 1 representing fraction of total
    # linestring length the point has to be located.
    #
    # See ST_Line_Locate_Point for computing the line location nearest to a Point.
    #
    # Returns geometry ST_Line_Interpolate_Point(geometry a_linestring, float a_fraction);
    #
    def interpolate_point(fraction)
      postgis_calculate(:line_interpolate_point, self, fraction)
    end

    #
    # Return a linestring being a substring of the input one starting and ending
    # at the given fractions of total 2d length. Second and third arguments are
    # float8 values between 0 and 1. This only works with LINESTRINGs. To use
    # with contiguous MULTILINESTRINGs use in conjunction with ST_LineMerge.
    #
    # If 'start' and 'end' have the same value this is equivalent to 'interpolate_point'.
    #
    # See 'locate_point' for computing the line location nearest to a Point.
    #
    # Returns geometry ST_Line_Substring(geometry a_linestring, float startfraction, float endfraction);
    #
    def line_substring(s,e)
      postgis_calculate(:line_substring, self, [s, e])
    end

    #Not implemented in postgis
    # ST_max_distance Returns the largest distance between two line strings.
    #def max_distance other
    #  postgis_calculate(:max_distance, [self, other])
    #end
  end

  ###
  ##
  #
  # Polygon
  #
  #
  module PolygonFunctions

    #
    # The area of the geometry if it is a polygon or multi-polygon.
    # Return the area measurement of an ST_Surface or ST_MultiSurface value.
    # Area is in the units of the spatial reference system.
    #
    # Returns Float ST_Area(geometry g1);
    #
    def area
      postgis_calculate(:area, self)
    end

    #
    # Returns the 2D perimeter of the geometry if it is a ST_Surface, ST_MultiSurface
    # (Polygon, Multipolygon). 0 is returned for non-areal geometries. For linestrings
    # use 'length'. Measurements are in the units of the spatial reference system of
    # the geometry.
    #
    # Returns Float ST_Perimeter(geometry g1);
    #
    def perimeter
      postgis_calculate(:perimeter, self)
    end

    #
    # Returns the 3-dimensional perimeter of the geometry, if it is a polygon or multi-polygon.
    # If the geometry is 2-dimensional, then the 2-dimensional perimeter is returned.
    #
    # Returns Float ST_Perimeter3D(geometry geomA);
    #
    def perimeter3d
      postgis_calculate(:perimeter3d, self)
    end

    #
    # True if the LineString's start and end points are coincident.
    #
    # This method implements the OpenGIS Simple Features Implementation
    # Specification for SQL.
    #
    # SQL-MM defines the result of ST_IsClosed(NULL) to be 0, while PostGIS returns NULL.
    #
    # Returns boolean ST_IsClosed(geometry g);
    #
    def closed?
      postgis_calculate(:isclosed, self)
    end
    alias_method "is_closed?", "closed?"

    #
    # True if no point in Geometry B is outside Geometry A
    #
    # This function call will automatically include a bounding box comparison
    # that will make use of any indexes that are available on the geometries.
    # To avoid index use, use the function _ST_Covers.
    #
    # Do not call with a GEOMETRYCOLLECTION as an argument
    # Do not use this function with invalid geometries. You will get unexpected results.
    #
    # Performed by the GEOS module.
    #
    # Returns Boolean ST_Covers(geometry geomA, geometry geomB);
    #
    def covers? other
      postgis_calculate(:covers, [self, other])
    end

  end

  ###
  ##
  #
  # Class Methods
  #
  # Falling back to AR here.
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

  private


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

  # Execute the query and parse the return.
  # We may receive:
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

  # Get a unique ID for tables
  def unique_identifier
    @u_id ||= "W1"
    @u_id = @u_id.succ
  end

end


  #
  #x SE_LocateAlong
  #x SE_LocateBetween

  #x ST_line_substring(linestring, start, end)

  #x ST_locate_along_measure(geometry, float8)   Return a derived geometry collection value with elements that match the specified measure. Polygonal elements are not supported.
  #x ST_locate_between_measures(geometry, float8, float8)
  #
  #x ST_Polygonize(geometry set)
  #x ST_SnapToGrid(geometry, geometry, sizeX, sizeY, sizeZ, sizeM)
  # ST_X , ST_Y, SE_M, SE_Z, SE_IsMeasured has_m?

  #x ST_Relate(geometry, geometry, intersectionPatternMatrix)


# POINT(0 0)
# LINESTRING(0 0,1 1,1 2)
# POLYGON((0 0,4 0,4 4,0 4,0 0),(1 1, 2 1, 2 2, 1 2,1 1))
# MULTIPOINT(0 0,1 2)
# MULTILINESTRING((0 0,1 1,1 2),(2 3,3 2,5 4))
# MULTIPOLYGON(((0 0,4 0,4 4,0 4,0 0),(1 1,2 1,2 2,1 2,1 1)), ..)
# GEOMETRYCOLLECTION(POINT(2 3),LINESTRING((2 3,3 4)))

#
#Accessors

#ST_Dump

#ST_ExteriorRing
#ST_GeometryN
#ST_GeometryType
#ST_InteriorRingN
#ST_IsEmpty
#ST_IsRing
#ST_IsSimple
#ST_IsValid
#ST_mem_size
#ST_M
#ST_NumGeometries
#ST_NumInteriorRings
#ST_PointN
#ST_SetSRID
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
#  end      #use all commands in lowcase form
      #opcode = opcode.camelize unless opcode =~ /spher|max|npoints/
