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

    # acts_as_geom :geom
    #
    #
    def acts_as_geom(geoms, options = {})
      cattr_accessor :postgis_geoms
      self.postgis_geoms = {:geoms => geoms, :opts => options}
      p geoms
      geoms.each do |g|
        case g.values.first
        when :point
          send :include, PointFunctions
        when :polygon
          send :include, PolygonFunctions
        when :line_string, :linestring
          send :include, LineStringFunctions
        end
      end
    end

    def get_geom_type(column)
      p column

    end
  end
end

ActiveRecord::Base.send :include, PostgisFunctions
