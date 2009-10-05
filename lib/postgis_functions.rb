# -*- coding: utf-8 -*-
#
# PostGIS Adapter - http://github.com/nofxx/postgis_adapter
#
# Hope you enjoy this plugin.
#
#
# Post any bugs/suggestions to GitHub issues tracker:
# http://github.com/nofxx/postgis_adapter/issues
#
#
# Some links:
#
# PostGis Manual - http://postgis.refractions.net/documentation/manual-svn/ch07.html
# Earth Spheroid - http://en.wikipedia.org/wiki/Figure_of_the_Earth
#

module PostgisFunctions
  # WGS84 Spheroid
  EARTH_SPHEROID = "'SPHEROID[\"GRS-80\",6378137,298.257222101]'" # SRID => 4326

  def postgis_calculate(operation, subjects, options = {})
    subjects = [subjects] unless subjects.respond_to?(:map)
    execute_geometrical_calculation(operation, subjects, options)
  end

  def geo_columns
    @geo_columns ||= postgis_geoms[:columns]
  end

  private

  #
  # Construct the PostGIS SQL query
  #
  # Returns:
  # Area/Distance/DWithin/Length/Perimeter  =>  projected units
  # DistanceSphere/Spheroid  =>  meters
  #
  def construct_geometric_sql(type,geoms,options)
    not_db, on_db = geoms.partition { |g| g.is_a? Geometry }

    tables = on_db.map do |t| {
      :name => t.class.table_name,
      :column => t.postgis_geoms.keys[0],
      :uid =>  unique_identifier,
      :id => t[:id] }
    end

    # Implement a better way for options?
    if options.instance_of? Hash
      transform = options.delete(:transform)
      options = nil
    end

    fields      = tables.map { |f| "#{f[:uid]}.#{f[:column]}" }     # W1.geom
    fields << not_db.map { |g| "'#{g.as_hex_ewkb}'::geometry"} unless not_db.empty?
    fields.map! { |f| "ST_Transform(#{f}, #{transform})" } if transform  # ST_Transform(W1.geom,x)
    conditions  = tables.map { |f| "#{f[:uid]}.id = #{f[:id]}" }         # W1.id = 5
    tables.map! { |f| "#{f[:name]} #{f[:uid]}" }                         # streets W1

    #
    # Data  =>  SELECT Func(A,B)
    # BBox  =>  SELECT (A <=> B)
    # Func  =>  SELECT Func(Func(A))
    #
    if type != :bbox
      opcode = type.to_s
      opcode = "ST_#{opcode}" unless opcode =~ /th3d|pesinter/
      fields << options if options
      fields = fields.join(",")
    else
      fields = fields.join(" #{options} ")
    end

    sql =  "SELECT #{opcode}(#{fields}) "
    sql << "FROM #{tables.join(",")} "         unless tables.empty?
    sql << "WHERE #{conditions.join(" AND ")}" unless conditions.empty?
    sql
  end

  #
  # Execute the query and parse the return.
  # We may receive:
  #
  # "t" or "f" for boolean queries
  # BIGHASH    for geometries
  # HASH       for ST_Relate
  # Rescue     a float
  #
  def execute_geometrical_calculation(operation, subject, options) #:nodoc:
    value = connection.select_value(construct_geometric_sql(operation, subject, options))
    return nil unless value
    # TODO: bench case vs if here
    if value =~ /^[tf]$/
      {"f" => false, "t" => true}[value]
    elsif value =~ /^\{/
       value
    else
      GeoRuby::SimpleFeatures::Geometry.from_hex_ewkb(value) rescue value
    end
    rescue Exception => e
    raise StandardError, "#{e}"
  end

  # Get a unique ID for tables
  def unique_identifier
    @u_id ||= "T1"
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
#  #EARTH_SPHEROID = "'SPHEROID[\"IERS_2003\",6378136.6,298.25642]'" # SRID =>
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
