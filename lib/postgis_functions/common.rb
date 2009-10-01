# -*- coding: utf-8 -*-
# #
#
# COMMON GEOMETRICAL FUNCTIONS
#
# The methods here can be used by all geoms.
#

module PostgisFunctions

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
    postgis_calculate(:distance, [self, other]).to_f
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


  def simplify!(tolerance=0.1)
    #FIXME: not good..
    self.update_attribute(geo_columns.first, simplify)
  end

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
  # Creates an areal geometry formed by the constituent linework of given geometry.
  # The return type can be a Polygon or MultiPolygon, depending on input.
  # If the input lineworks do not form polygons NULL is returned. The inputs can
  # be LINESTRINGS, MULTILINESTRINGS, POLYGONS, MULTIPOLYGONS, and GeometryCollections.
  #
  # Returns Boolean ST_BuildArea(geometry A);
  #
  def build_area
    postgis_calculate(:buildarea, self)
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

  #
  # Aggregate. Creates a GeometryCollection containing possible polygons formed
  # from the constituent linework of a set of geometries.
  #
  # Geometry Collections are often difficult to deal with with third party tools,
  # so use ST_Polygonize in conjunction with ST_Dump to dump the polygons out into
  #  individual polygons.
  #
  # Returns Geometry ST_Polygonize(geometry set geomfield);
  #
  def polygonize
    postgis_calculate(:polygonize, self)
  end

  #
  # Returns true if this Geometry is spatially related to anotherGeometry,
  # by testing for intersections between the Interior, Boundary and Exterior
  # of the two geometries as specified by the values in the
  # intersectionPatternMatrix. If no intersectionPatternMatrix is passed in,
  # then returns the maximum intersectionPatternMatrix that relates the 2 geometries.
  #
  #
  # Version 1: Takes geomA, geomB, intersectionMatrix and Returns 1 (TRUE) if
  # this Geometry is spatially related to anotherGeometry, by testing for
  # intersections between the Interior, Boundary and Exterior of the two
  # geometries as specified by the values in the intersectionPatternMatrix.
  #
  # This is especially useful for testing compound checks of intersection,
  # crosses, etc in one step.
  #
  # Do not call with a GeometryCollection as an argument
  #
  # This is the "allowable" version that returns a boolean, not an integer.
  # This is defined in OGC spec.
  # This DOES NOT automagically include an index call. The reason for that
  # is some relationships are anti e.g. Disjoint. If you are using a relationship
  # pattern that requires intersection, then include the && index call.
  #
  # Version 2: Takes geomA and geomB and returns the DE-9IM
  # (dimensionally extended nine-intersection matrix)
  #
  # Do not call with a GeometryCollection as an argument
  # Not in OGC spec, but implied. see s2.1.13.2
  #
  #  Both Performed by the GEOS module
  #
  #  Returns:
  #
  #  String ST_Relate(geometry geomA, geometry geomB);
  #  Boolean ST_Relate(geometry geomA, geometry geomB, text intersectionPatternMatrix);
  #
  def relate?(other, m = nil)
    # Relate is case sentitive.......
    m = "'#{m}'" if m
    postgis_calculate("Relate", [self, other], m)
  end

  #
  # Transform the geometry into a different spatial reference system.
  # The destination SRID must exist in the SPATIAL_REF_SYS table.
  #
  # This method implements the OpenGIS Simple Features Implementation Specification for SQL.
  # This method supports Circular Strings and Curves (PostGIS 1.3.4+)
  #
  # Requires PostGIS be compiled with Proj support.
  #
  # Return Geometry ST_Transform(geometry g1, integer srid);
  #
  def transform!(new_srid)
    self[postgis_geoms.keys[0]] = postgis_calculate("Transform", self.new_record? ? self.geom : self, new_srid)
  end

  def transform(new_srid)
    dup.transform!(new_srid)
  end

  #
  # Returns a modified geometry having no segment longer than the given distance.
  # Distance computation is performed in 2d only.
  #
  # This will only increase segments. It will not lengthen segments shorter than max length
  #
  # Return Geometry ST_Segmentize(geometry geomA, float max_length);
  #
  def segmentize(max_length=1.0)
    postgis_calculate("segmentize", self, max_length)
  end

  #
  # Returns the instance`s geom srid
  #
  def srid
    self[postgis_geoms.keys.first].srid
  end

  #
  # Return UTM Zone for a geom
  #
  # Return Integer
  def utm_zone
    if srid == 4326
      geom = centroid
    else
      geomdup = transform(4326)
      mezzo = geomdup.length / 2
      geom = case geomdup
             when Point      then  geomdup
             when LineString then  geomdup[mezzo]
             else
               geomgeog[mezzo][geomgeo[mezzo]/2]
             end

    end

    pref = geom.y > 0 ? 32700 : 32600
    zone = ((geom.x + 180) / 6 + 1).to_i
    zone + pref
  end

  #
  # Returns the Geometry in its UTM Zone
  #
  # Return Geometry
  def to_utm!(utm=nil)
    utm ||= utm_zone
    self[postgis_geoms.keys.first] = transform(utm)
  end

  def to_utm
    dup.to_utm!
  end

  #
  # Returns Geometry as GeoJSON
  #
  # http://geojson.org/
  #
  def as_geo_json
    postgis_calculate(:AsGeoJSON, self)
  end


  #
  #
  # LINESTRING
  #
  #
  #
  module LineStringFunctions

    #
    # Returns the 2D length of the geometry if it is a linestring, multilinestring,
    # ST_Curve, ST_MultiCurve. 0 is returned for areal geometries. For areal geometries
    # use 'perimeter'. Measurements are in the units of the spatial reference system
    # of the geometry.
    #
    # Returns Float
    #
    def length
      postgis_calculate(:length, self).to_f
    end

    #
    # Returns the 3-dimensional or 2-dimensional length of the geometry if it is
    # a linestring or multi-linestring. For 2-d lines it will just return the 2-d
    # length (same as 'length')
    #
    # Returns Float
    #
    def length_3d
      postgis_calculate(:length3d, self).to_f
    end

    #
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
    # Returns Float length_spheroid(geometry linestring, spheroid);
    #
    def length_spheroid(spheroid = EARTH_SPHEROID)
      postgis_calculate(:length_spheroid, self, spheroid).to_f
    end

    #
    # Return the number of points of the geometry.
    # PostGis ST_NumPoints does not work as nov/08
    #
    # Returns Integer ST_NPoints(geometry g1);
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
    # Returns geometry end point.
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
    # Warning: PostGIS 1.4+
    #
    # Return crossing direction
    def line_crossing_direction(other)
      postgis_calculate(:lineCrossingDirection, [self, other])
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
      postgis_calculate(:line_locate_point, [self, point]).to_f
    end

    #
    # Return a derived geometry collection value with elements that match the
    # specified measure. Polygonal elements are not supported.
    #
    # Semantic is specified by: ISO/IEC CD 13249-3:200x(E) - Text for
    # Continuation CD Editing Meeting
    #
    # Returns geometry ST_Locate_Along_Measure(geometry ageom_with_measure, float a_measure);
    #
    def locate_along_measure(measure)
      postgis_calculate(:locate_along_measure, self, measure)
    end

    #
    # Return a derived geometry collection value with elements that match the
    # specified range of measures inclusively. Polygonal elements are not supported.
    #
    # Semantic is specified by: ISO/IEC CD 13249-3:200x(E) - Text for Continuation CD Editing Meeting
    #
    # Returns geometry ST_Locate_Between_Measures(geometry geomA, float measure_start, float measure_end);
    #
    def locate_between_measures(a, b)
      postgis_calculate(:locate_between_measures, self, [a,b])
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

    ###
    #Not implemented in postgis yet
    # ST_max_distance Returns the largest distance between two line strings.
    #def max_distance other
    # #float ST_Max_Distance(geometry g1, geometry g2);
    #  postgis_calculate(:max_distance, [self, other])
    #end
  end


  #
  #
  #
  #
  # POINT
  #
  #
  #
  #
  module PointFunctions

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
      postgis_calculate(:line_locate_point, [line, self]).to_f
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
      postgis_calculate(:distance_sphere, [self, other]).to_f
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
      postgis_calculate(:distance_spheroid, [self, other], spheroid).to_f
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
      postgis_calculate(:azimuth, [self, other]).to_f
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

  #
  #
  #
  #
  # Polygon
  #
  #
  #
  #
  module PolygonFunctions

    #
    # The area of the geometry if it is a polygon or multi-polygon.
    # Return the area measurement of an ST_Surface or ST_MultiSurface value.
    # Area is in the units of the spatial reference system.
    #
    # Accepts optional parameter, the srid to transform to.
    #
    # Returns Float ST_Area(geometry g1);
    #
    def area transform=nil
      postgis_calculate(:area, self, { :transform => transform }).to_f
    end

    #
    # Returns the 2D perimeter of the geometry if it is a ST_Surface, ST_MultiSurface
    # (Polygon, Multipolygon). 0 is returned for non-areal geometries. For linestrings
    # use 'length'. Measurements are in the units of the spatial reference system of
    # the geometry.
    #
    # Accepts optional parameter, the sridto transform to.
    #
    # Returns Float ST_Perimeter(geometry g1);
    #
    def perimeter transform=nil
      postgis_calculate(:perimeter, self, { :transform => transform }).to_f
    end

    #
    # Returns the 3-dimensional perimeter of the geometry, if it is a polygon or multi-polygon.
    # If the geometry is 2-dimensional, then the 2-dimensional perimeter is returned.
    #
    # Returns Float ST_Perimeter3D(geometry geomA);
    #
    def perimeter3d
      postgis_calculate(:perimeter3d, self).to_f
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

end

# NEW
#ST_OrderingEquals — Returns true if the given geometries represent the same geometry and points are in the same directional order.
#boolean ST_OrderingEquals(g
#  ST_PointOnSurface — Returns a POINT guaranteed to lie on the surface.
#geometry ST_PointOnSurface(geometry g1);eometry A, geometry B);


#x ST_SnapToGrid(geometry, geometry, sizeX, sizeY, sizeZ, sizeM)
# ST_X , ST_Y, SE_M, SE_Z, SE_IsMeasured has_m?
