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

    # acts_as_geom :db_field => :geom_type
    # Examples:
    #
    # acts_as_geom :data => :point
    # acts_as_geom :geom => :line_string
    # acts_as_geom :geom => :polygon
    #
    def acts_as_geom(*geom)
      cattr_accessor :postgis_geoms
      self.postgis_geoms = geom[0] # {:columns => column
      send :include, case geom[0].values[0]
        when :point       then  PointFunctions
        when :polygon     then PolygonFunctions
        when :line_string then  LineStringFunctions
      end unless geom[0].kind_of? Symbol
    end

    def get_geom_type(column)
      self.postgis_geoms.values[0] rescue nil
    #   self.columns.select { |c| c.name == column.to_s }[0].geometry_type
    # rescue ActiveRecord::StatementInvalid => e
    #   nil
    end
  end
end

ActiveRecord::Base.send :include, PostgisFunctions
