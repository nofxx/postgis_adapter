module PostgisAdapter
module Functions

    #
    # Class Methods
    #
    module ClassMethods

      #
      # Returns the closest record
      def closest_to(p, opts = {})
        srid = opts.delete(:srid) || p.srid || 4326
        opts.merge!(:order => "ST_Distance(geom, GeomFromText('#{p.text_geometry_type}(#{p.text_representation})', #{srid}))")
        find(:first, opts)
      end

      #
      # Order by distance
      def close_to(p, opts = {})
        srid = opts.delete(:srid) || p.srid || 4326
        opts.merge!(:order => "ST_Distance(geom, GeomFromText('#{p.text_geometry_type}(#{p.text_representation})', #{srid}))")
        find(:all, opts)
      end

      def by_length opts = {}
        sort = opts.delete(:sort) || 'asc'
        opts.merge!(:order => "ST_length(geom) #{sort}")
        find(:all, opts)
      end

      def longest
        find(:first, :order => "ST_length(geom) DESC")
      end

      def contains(p, srid=nil)
        srid = srid || p.srid || 4326
        find(:all, :conditions => ["ST_Contains(geom, GeomFromText('#{p.text_geometry_type}(#{p.text_representation})', #{srid}))"])
      end

      def contain(p, srid=nil)
        srid = srid || p.srid || 4326
        find(:first, :conditions => ["ST_Contains(geom, GeomFromText('#{p.text_geometry_type}(#{p.text_representation})', #{srid}))"])
      end

      def by_area(sort='asc')
        find(:all, :order => "ST_Area(geom) #{sort}" )
      end

      def by_perimeter(sort='asc')
        find(:all, :order => "ST_Perimeter(geom) #{sort}" )
      end

      def all_dwithin(other, margin=1)
        # find(:all, :conditions => "ST_DWithin(geom, ST_GeomFromEWKB(E'#{other.as_ewkt}'), #{margin})")
        find(:all, :conditions => "ST_DWithin(geom, ST_GeomFromEWKT(E'#{other.as_hex_ewkb}'), #{margin})")
      end

      def all_within(other)
        find(:all, :conditions => "ST_Within(geom, ST_GeomFromEWKT(E'#{other.as_hex_ewkb}'))")
      end

      def by_boundaries(sort='asc')
        find(:all, :order => "ST_Boundary(geom) #{sort}" )
      end

      #
      # Return records which covered by geometry
      def covered_by(gometry, srid=nil)
        srid = srid || geometry.srid || 4326
        find(:all, :conditions => "ST_CoveredBy(geom, GeomFromText('#{geometry.text_geometry_type}(#{geometry.text_representation})', #{srid}))")
      end

    end

end
end
