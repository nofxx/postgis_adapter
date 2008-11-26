class SpatialAdapterNotCompatibleError < StandardError
end

unless ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
  raise SpatialAdapterNotCompatibleError.
    new("Only PostgreSQL with PostGIS is supported by the postgis adapter plugin.")
end

require 'post_gis_adapter'
