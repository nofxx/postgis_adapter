# #
#
# PostGIS Adapter - http://github.com/nofxx/postgis_adapter
#
# Hope you enjoy this plugin. 
# 
#
#
# Post any bugs/suggestions to the lighthouse tracker:
# http://nofxx.lighthouseapp.com/projects/20712-postgisadapter
#
#
# Some links:
#
# PostGis Manual -  http://postgis.refractions.net/documentation/manual-svn/ch07.html
# Earth Spheroid - http://en.wikipedia.org/wiki/Figure_of_the_Earth
#
#
#
module PostgisFunctions
  # EARTH_SPHEROID = "'SPHEROID[\"GRS-80\",6378137,298.257222101]'"

  EARTH_SPHEROID = "'SPHEROID[\"IERS_2003\",6378136.6,298.25642]'"

  def postgis_calculate(operation, subjects, options = nil)
    subjects = [subjects] unless subjects.respond_to?(:map)
    return execute_geometrical_calculation(operation, subjects, options)
    rescue Exception => e
    raise StandardError, "#{e}"
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

    fields      = tables.map { |f| "#{f[:uid]}.geom" }            # W1.geom
    conditions  = tables.map { |f| "#{f[:uid]}.id = #{f[:id]}" }  # W1.id = 5
    tables.map! { |f| "#{f[:class]} #{f[:uid]}" }    # streets W1
    
    #
    # Data =>  SELECT Func(A,B)
    # BBox =>  SELECT (A <=> B)
    #
    if type == :bbox
      opcode = nil
      s_join = " #{options} "
    else
      opcode = type.to_s
      opcode = "ST_#{opcode}" unless opcode =~ /th3d|pesinter/
      s_join = ","
      fields << options if options
    end

    sql =   "SELECT #{opcode}(#{fields.join(s_join)}) "
    sql <<  "FROM #{tables.join(",")} "           if tables
    sql <<  "WHERE #{conditions.join(" AND ")}"   if conditions
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
    return nil unless value
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
# POINT(0 0)
# LINESTRING(0 0,1 1,1 2)
# POLYGON((0 0,4 0,4 4,0 4,0 0),(1 1, 2 1, 2 2, 1 2,1 1))
# MULTIPOINT(0 0,1 2)
# MULTILINESTRING((0 0,1 1,1 2),(2 3,3 2,5 4))
# MULTIPOLYGON(((0 0,4 0,4 4,0 4,0 0),(1 1,2 1,2 2,1 2,1 1)), ..)
# GEOMETRYCOLLECTION(POINT(2 3),LINESTRING((2 3,3 4)))
#
#Accessors
#
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
# 
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
