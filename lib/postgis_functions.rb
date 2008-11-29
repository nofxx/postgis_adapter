# #
# COMMON STUFF
#
#
module PostgisFunctions

  def construct_geometric_sql(type,a,b)
   table1 = a.class.to_s.downcase.pluralize
   table2 = b.class.to_s.downcase.pluralize
   field1 = table1 + ".geom"
   field2 = table2 + ".geom"

   p query = "SELECT #{type.capitalize}(#{field1},#{field2}) FROM #{table1},#{table2} "+
    "WHERE #{table1}.id=#{a[:id]} AND #{table2}.id=#{b[:id]}"
    query
   end

   def to_bool(v)
     {"f" => false, "t" => true}[v]
   end
end


# #
# AREA
#
#
module AreaFunctions

  class << self

    def included base #:nodoc:
      base.extend ClassMethods
    end

    module ClassMethods
      def has_area column="geom"
        include InstanceMethods
      end

      def contains?
        true
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
        to_bool(self.class.connection.select_value(construct_geometric_sql("contains", self, other)))
      end
      alias_method "within?", "contains?"

      def intersects? other
        to_bool(self.class.count_by_sql(construct_geometric_sql("intesects", self, other)))
      end


    end
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
         self.class.connection.select_value(construct_geometric_sql("distance", self, other)).to_f
       end

       def inside? other
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








#  # Set it all up.
#if Object.const_defined?("ActiveRecord")
##p  ActiveRecord::Base.subclasses
# # ActiveRecord::Base.send(:include, PostgisFunctions)
#   # ActiveRecord::Base.send(:include, PolygonFunctions)
#  #File.send(:include, Paperclip::Upfile)
#end


#  def close_to(point)
#    lambda { |p| {:order => "Distance(geom, GeomFromText('POINT(#{p.x} #{p.y})', 4326))" }}
#  end
#  def x;  geom ? geom.x : nil;  end
#  def y;  geom ? geom.y : nil;  end
#  def z;  geom ? geom.z : nil;  end
#module Area

#  def geometrical_attr
#    @geomtrical_attr
#  end

#  def has_area(name)
#  end


#  def self.contains
#  end
#      def geo_columns
#        @@geo_columns
#      end

#      def geo_columns_add(c)
#        @@geo_columns ||= []
#        @@geo_columns << c
#      end

#      def has_point(p)
#        p = [p] unless p.respond_to?(:each)
#        p.each { |p| geo_columns_add({:point => p}) }
#      end

#      def has_polygon(p)
#        geo_columns_add({:polygon => p})
#      end

#      def has_line_string(ln)
#      end

#  def contains?(geo)
#     superclass.columns.each do |c|
#     p c.type
#    end
##"SELECT ST_Distance(#{klass.to_s.downcase.pluralize}.#{column_name}, GeomFromText('POINT(#{x} #{y})', #{srid})) FROM routes WHERE routes.geom.id = #{id}")
#  end

#  def self.within(area)
#  p area.class

#     find_by_sql('SELECT * FROM "positions","areas" WHERE Within(positions.geom, areas.geom)') #{area.class.to_s.downcase}.geom)"])
#  end



#  end
#  module Point

#  def self.distance(geom)
#    #count_by_sql('SELECT "Distance(geom, GeomFromText('POINT(#"')
#  end



#end

#end

#class GeoRuby::SimpleFeatures::Point

#  # Poi.geom.closest(Restaurant).all
#  # Poi.geom.closest(:restaurant).all
#  def closest(klass, column_name="geom",srid=4326)
#  p klass.to_s.constantize.classify
#    klass.to_s.constantize.classify.find(:first, :order => "Distance(#{column_name}, GeomFromText('POINT(#{x} #{y})', #{srid}))")
#  end

#  def distance(klass, column_name="geom",srid=4326)
#    klass.connection.count_by_sql("SELECT ST_Distance(#{klass.to_s.downcase.pluralize}.#{column_name}, GeomFromText('POINT(#{x} #{y})', #{srid})) FROM routes WHERE routes.geom.id = #{id}")
#  end

#  def inside?(klass,polygon)
#    "geom WITHIN(polygon)"
#  end

#  def outside?
#    !inside?
#  end



#class GeoRuby::SimpleFeatures::LineString
#class GeoRuby::SimpleFeatures::Polygon
#class GeoRuby::SimpleFeatures::Geometry
#class GeoRuby::SimpleFeatures::MultiPoint

#ST_Contains
#ST_CoveredBy
#ST_Covers
#ST_Crosses
#ST_Disjoint
#ST_DWithin
#ST_Equals
#ST_Intersects
#ST_Overlaps
#ST_Relate
#ST_Touches
#ST_Within
#ST_Area
#ST_Azimuth
#ST_Distance
#ST_distance_sphere
#ST_distance_spheroid
#ST_length_spheroid
#ST_length
#length3d_spheroid
#ST_max_distance
#ST_Perimeter
