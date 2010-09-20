#
# PostGIS Adapter
#
# http://github.com/nofxx/postgis_adapter
#
module PostgisAdapter
module Functions
  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods

    # has_geom :db_field => :geom_type
    # Examples:
    #
    # has_geom :data => :point
    # has_geom :geom => :line_string
    # has_geom :geom => :polygon
    #
    def has_geom(*geom)
      cattr_accessor :postgis_geoms
      self.postgis_geoms = geom[0] # {:columns => column
      send :include, case geom[0].values[0]
        when :point       then  PointFunctions
        when :polygon     then PolygonFunctions
        when :line_string, :multi_line_string then  LineStringFunctions
        when :multi_polygon then MultiPolygonFunctions
      end unless geom[0].kind_of? Symbol
    end
    alias :acts_as_geom :has_geom

    def get_geom_type(column)
      self.postgis_geoms.values[0] rescue nil
    #   self.columns.select { |c| c.name == column.to_s }[0].geometry_type
    # rescue ActiveRecord::StatementInvalid => e
    #   nil
    end
  end
end
end

ActiveRecord::Base.send :include, PostgisAdapter::Functions
