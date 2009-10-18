class SpatialAdapterNotCompatibleError < StandardError
end

unless ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
  raise SpatialAdapterNotCompatibleError.
    new("Database config file not set or it does not map to PostgreSQL\n" +
        "Only PostgreSQL with PostGIS is supported by postgis_adapter.")
end
require 'postgis_adapter'
