module PostgisFunctions
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
  
end