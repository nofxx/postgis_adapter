module PostgisFunctions
####
###
##
#
# LINESTRING
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
      dis = postgis_calculate(:length, self).to_f
    end

    #
    # Returns the 3-dimensional or 2-dimensional length of the geometry if it is
    # a linestring or multi-linestring. For 2-d lines it will just return the 2-d
    # length (same as 'length')
    #
    # Returns Float
    #
    def length_3d
      dis = postgis_calculate(:length3d, self).to_f
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
      dis = postgis_calculate(:length_spheroid, self, spheroid).to_f
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
end