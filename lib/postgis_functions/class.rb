module PostgisFunctions
  
  
    ###
    ##
    #
    # Class Methods
    #
    # Falling back to AR here.
    #
    module ClassMethods

      def closest_to(p, srid=4326)
        find(:first, :order => "ST_Distance(geom, GeomFromText('POINT(#{p.x} #{p.y})', #{srid}))" )
      end

      def close_to(p, srid=4326)
        find(:all, :order => "ST_Distance(geom, GeomFromText('POINT(#{p.x} #{p.y})', #{srid}))" )
      end

      def by_size sort='asc'
        find(:all, :order => "ST_length(geom) #{sort}" )
      end

      def longest
        find(:first, :order => "ST_length(geom) DESC")
      end

      def contains(p, srid=4326)
        find(:all, :conditions => ["ST_Contains(geom, GeomFromText('POINT(#{p.x} #{p.y})', #{srid}))"])
      end

      def contain(p, srid=4326)
        find(:first, :conditions => ["ST_Contains(geom, GeomFromText('POINT(#{p.x} #{p.y})', #{srid}))"])
      end

      def by_area sort='asc'
        find(:all, :order => "ST_Area(geom) #{sort}" )
      end

      def by_perimeter sort='asc'
        find(:all, :order => "ST_Perimeter(geom) #{sort}" )
      end

      def all_within(other, margin=1)
  #      find(:all, :conditions => "ST_DWithin(geom, ST_GeomFromEWKB(E'#{other.as_ewkt}'), #{margin})")
        find(:all, :conditions => "ST_DWithin(geom, ST_GeomFromEWKT(E'#{other.as_hex_ewkb}'), #{margin})")
      end

      def by_boundaries sort='asc'
        find(:all, :order => "ST_Boundary(geom) #{sort}" )
      end

    end
  
  
  
end