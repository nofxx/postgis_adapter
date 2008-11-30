# #
# PostGIS Adapter
#
#
# http://github.com/nofxx/postgis_adapter
#
module PostgisFunctions
  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
    def acts_as_geom(geoms, options = {})
      cattr_accessor :postgis_geoms
      self.postgis_geoms = {:geoms => geoms, :opts => options}
      geoms.each do |g|
        case g.values.first
        when :point
          include PointFunctions
        when :polygon
          include PolygonFunctions
        when :line_string, :linestring
          include LineStringFunctions
        end
      end
    end

          def has_point column="geom"
        include InstanceMethods
        has_geom_options = {:column => column}
      end

      def close_to(p, srid=4326)
        find(:all, :order => "Distance(geom, GeomFromText('POINT(#{p.x} #{p.y})', #{srid}))" )
      end

      def closest_to(p, srid=4326)
        find(:first, :order => "Distance(geom, GeomFromText('POINT(#{p.x} #{p.y})', #{srid}))" )
      end

            def close_to(p, srid=4326)
        find(:first, :order => "Distance(geom, GeomFromText('POINT(#{p.x} #{p.y})', #{srid}))" )
      end

      def by_size sort='asc'
        find(:all, :order => "length(geom) #{sort}" )
      end

      def longest
        find(:first, :order => "length(geom) DESC")
      end


      def contains(p, srid=4326)
        find(:all, :conditions => ["ST_Contains(geom, GeomFromText('POINT(#{p.x} #{p.y})', #{srid}))"])
      end

      def contain(p, srid=4326)
        find(:first, :conditions => ["ST_Contains(geom, GeomFromText('POINT(#{p.x} #{p.y})', #{srid}))"])
      end

      def close_to(p, srid=4326)
        find(:all, :order => "Distance(geom, GeomFromText('POINT(#{p.x} #{p.y})', #{srid}))" )
      end

      def closest_to(p, srid=4326)
        find(:first, :order => "Distance(geom, GeomFromText('POINT(#{p.x} #{p.y})', #{srid}))" )
      end

      def by_size sort='asc'
        find(:all, :order => "Area(geom) #{sort}" )
      end

      def by_perimeter sort='asc'
        find(:all, :order => "Perimeter(geom) #{sort}" )
      end
  end
end

ActiveRecord::Base.send :include, PostgisFunctions
