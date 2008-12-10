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
  def polygonize#(geom)
    postgis_calculate(:polygonize, self)
  end
  
  # NEW
  #ST_OrderingEquals — Returns true if the given geometries represent the same geometry and points are in the same directional order.
  #boolean ST_OrderingEquals(g
  #  ST_PointOnSurface — Returns a POINT guaranteed to lie on the surface.
  #geometry ST_PointOnSurface(geometry g1);eometry A, geometry B);


  #x ST_SnapToGrid(geometry, geometry, sizeX, sizeY, sizeZ, sizeM)
  # ST_X , ST_Y, SE_M, SE_Z, SE_IsMeasured has_m?

  #x ST_Relate(geometry, geometry, intersectionPatternMatrix)
  
  
  
  
  
end