module PostgisFunctions
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
  
end