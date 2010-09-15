# Patching Arel to support geometry type
# https://rails.lighthouseapp.com/projects/8994/tickets/4270-arel-032-broke-non-standard-column-types
# https://rails.lighthouseapp.com/projects/8994/tickets/5194-activerecord-beta-4-does-not-understand-most-postgres-data-types

module Arel
  module Sql
    module Attributes
      def self.for(column)
        case column.type
        when :string    then String
        when :text      then String
        when :integer   then Integer
        when :float     then Float
        when :decimal   then Decimal
        when :date      then Time
        when :datetime  then Time
        when :timestamp then Time
        when :time      then Time
        when :binary    then String
        when :boolean   then Boolean
        when :geometry  then String
        else
          raise NotImplementedError, "Column type `#{column.type}` is not currently handled"
        end
      end
    end
  end
end

class SpatialAdapterNotCompatibleError < StandardError
end

unless ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
  raise SpatialAdapterNotCompatibleError.
    new("Database config file not set or it does not map to PostgreSQL\n" +
        "Only PostgreSQL with PostGIS is supported by postgis_adapter.")
end
require 'postgis_adapter'
