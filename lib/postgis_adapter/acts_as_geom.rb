#
# PostGIS Adapter
#
# http://github.com/nofxx/postgis_adapter
#
module PostgisFunctions
  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods

    # acts_as_geom :geom
    def acts_as_geom(*columns)
      cattr_accessor :postgis_geoms
      self.postgis_geoms = {:columns => columns}
      columns.map do |g|
        case get_geom_type(g)
        when :point then send :include, PointFunctions
        when :polygon then send :include, PolygonFunctions
        when :line_string then send :include, LineStringFunctions
        end
      end
    end

    def get_geom_type(column)
      self.columns.select { |c| c.name == column.to_s }[0].geometry_type
    rescue ActiveRecord::StatementInvalid => e
      nil
    end
  end
end

ActiveRecord::Base.send :include, PostgisFunctions
