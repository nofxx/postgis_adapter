# #
# PostGIS Adapter
#
#
# http://github.com/nofxx/postgis_adapter
#
# Thanks to the great Spatial Adapter by Guilhem Vellut
#
module PostgisFunctions

  # Postgis Functions:
  #
  # ST_Contains  ST_Covers   ST_Within   ST_CoveredBy  ST_DWithin
  # ST_Overlaps  ST_Relate   ST_Disjoint
  # ST_Touches   ST_Crosses  ST_Intersects
  # ST_Equals    ST_Azimuth
  # ST_Distance  ST_distance_sphere  ST_distance_spheroid ST_max_distance
  # ST_length    ST_length_spheroid  length3d_spheroid
  # ST_Area      ST_Perimeter
  def construct_geometric_sql(type,a,b)

   tables = [a,b].map { |t| t.class.to_s.downcase.pluralize }
   fields = tables.map { |f| f + ".geom" }
   operation = type.to_s
   operation.capitalize! unless operation =~ /length|spher|max/
   operation = "ST_#{operation}" unless operation =~ /th3d/

    sql =   "SELECT #{operation}(#{fields.join(",")}) "+
            "FROM #{tables.join(",")} "+
            "WHERE #{tables[0]}.id=#{a[:id]} "
    sql <<  "AND #{tables[1]}.id=#{b[:id]} " if b
    p sql
    sql
   end

  def execute_geometric_calculation(operation, subject, options)#0# column, options) #:nodoc:
    value = connection.select_value(construct_geometric_sql(operation, subject, options))
    #type_cast_calculated_value(value, column, operation)
  end

  def execute_relational_calculation(operation, subjects, options) #:nodoc:
    value = connection.select_value(construct_geometric_sql(operation, subjects[0], subjects[1]))#, options))
    if value =~ /^\D/
      to_bool(value)
    else
      value.to_f
    end
    #type_cast_calculated_value(value, column, operation)
  end

  def calculate(operation, subject, options = {})
    if subject.instance_of?(Array)
      return execute_relational_calculation(operation, subject, options)
    else
      return execute_geometric_calculation(operation, subject, options)
    end
  end

   def to_bool val
     {"f" => false, "t" => true}[val]
   end
end



# #
# POINT
#
#
#
#
module PointFunctions
  class << self

    def included base #:nodoc:
      base.extend ClassMethods
    end

    module ClassMethods

      def has_point column="geom"
        include InstanceMethods
      end

      def close_to(other, srid=4326)
        find(:first, :order => "Distance(geom, GeomFromText('POINT(#{other.geom.x} #{other.geom.y})', #{srid}))" )
      end

    end

    module InstanceMethods
      include PostgisFunctions

      def distance other
        calculate(:distance, [self, other])
      end

      def inside? other
        calculate(:contains, [other, self])
      end

      def outside? other
        !inside? other
      end
    end
  end
end


# #
# LINESTRING
#
#
#
#
#
module LineStringFunctions

  class << self

    def included base #:nodoc:
      base.extend ClassMethods
    end

    module ClassMethods
      def has_line_string column="geom"
        include InstanceMethods
      end

      def close_to(p, srid=4326)
        find(:first, :order => "Distance(geom, GeomFromText('POINT(#{p.x} #{p.y})', #{srid}))" )
      end

      def by_size sort='asc'
        find(:all, :order => "length(geom) #{sort}" )
      end

    end

    module InstanceMethods
      def length
        self.class.connection.select_value("SELECT length(geom) FROM #{self.class.to_s.pluralize} WHERE id=#{self[:id]}").to_f
      end


      def intersects? other
        to_bool(self.class.count_by_sql(geometric_query("intersects", self, other)))
      end
    end
  end
end





# #
# Polygon
#
#
module PolygonFunctions

  class << self

    def included base #:nodoc:
      base.extend ClassMethods
    end

    module ClassMethods
      def has_area column="geom"
        include InstanceMethods
      end

      def contains(p, srid=4326)
        find(:all, :conditions => ["ST_Contains(geom, GeomFromText('POINT(#{p.x} #{p.y})', #{srid}))"])
      end

      def close_to(p, srid=4326)
        find(:first, :order => "Distance(geom, GeomFromText('POINT(#{p.x} #{p.y})', #{srid}))" )
      end

      def by_size sort='asc'
        find(:all, :order => "Area(geom) #{sort}" )
      end

      def by_perimeter sort='asc'
        find(:all, :order => "Perimeter(geom) #{sort}" )
      end


    end

    module InstanceMethods
      include PostgisFunctions

      def area
        self.class.connection.select_value("SELECT Area(geom) FROM #{self.class.to_s.pluralize} WHERE id=#{self[:id]}").to_f
      end

      def contains? other
        calculate(:contains, [self, other])
      end
      alias_method "within?", "contains?"

      def intersects? other
        calculate(:intesects, [self, other])
      end

      def covers? other
        calculate(:covers, [self, other])
      end

    end
  end
end




#if Object.const_defined?("ActiveRecord")
# ActiveRecord::Base.send(:include, PostgisFunctions)
#end
#      def has_point(p)
#        p = [p] unless p.respond_to?(:each)
#        p.each { |p| geo_columns_add({:point => p}) }
#      end
#      def has_polygon(p)
#        geo_columns_add({:polygon => p})
#      end
#      def has_line_string(ln)
#      end
#class GeoRuby::SimpleFeatures::Point
#class GeoRuby::SimpleFeatures::LineString
#class GeoRuby::SimpleFeatures::Polygon
#class GeoRuby::SimpleFeatures::Geometry
#class GeoRuby::SimpleFeatures::MultiPoint
