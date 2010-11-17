# Patch Arel to support geometry type.
module Arel
  module Attributes
    class << self
      alias original_for for

      def for(column)
        case column.type
        when :geometry then String
        else
          original_for(column)
        end
      end
    end
  end
end

class SpatialAdapterNotCompatibleError < StandardError
end

unless ActiveRecord::Base.connection.adapter_name.downcase == 'postgresql'
  error_message = "Database config file not set or it does not map to "
  error_message << "PostgreSQL.\nOnly PostgreSQL with PostGIS is supported "
  error_message << "by postgis_adapter.")
  raise SpatialAdapterNotCompatibleError.new(error_message)
end

require 'postgis_adapter'
