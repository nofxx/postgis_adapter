#
# PostGIS Adapter
#
#
# Code from
# http://georuby.rubyforge.org Spatial Adapter
#
require 'active_record'
require 'active_record/connection_adapters/postgresql_adapter'
require 'geo_ruby'
require 'postgis_adapter/common_spatial_adapter'
require 'postgis_adapter/functions'
require 'postgis_adapter/functions/common'
require 'postgis_adapter/functions/class'
require 'postgis_adapter/functions/bbox'
require 'postgis_adapter/acts_as_geom'

include GeoRuby::SimpleFeatures
include SpatialAdapter

module PostgisAdapter
  IGNORE_TABLES = %w{ spatial_ref_sys geometry_columns geography_columns }
end
#tables to ignore in migration : relative to PostGIS management of geometric columns
ActiveRecord::SchemaDumper.ignore_tables.concat PostgisAdapter::IGNORE_TABLES

#add a method to_yaml to the Geometry class which will transform a geometry in a form suitable to be used in a YAML file (such as in a fixture)
GeoRuby::SimpleFeatures::Geometry.class_eval do
  def to_fixture_format
    as_hex_ewkb
  end
end

ActiveRecord::Base.class_eval do

  #Vit Ondruch & Tilmann Singer 's patch
  def self.get_conditions(attrs)
    attrs.map do |attr, value|
      attr = attr.to_s
      column_name = connection.quote_column_name(attr)
      if columns_hash[attr].is_a?(SpatialColumn)
        if value.is_a?(Array)
          attrs[attr.to_sym]= "BOX3D(" + value[0].join(" ") + "," + value[1].join(" ") + ")"
          "#{table_name}.#{column_name} && SetSRID(?::box3d, #{value[2] || @@default_srid || DEFAULT_SRID} ) "
        elsif value.is_a?(Envelope)
          attrs[attr.to_sym]= "BOX3D(" + value.lower_corner.text_representation + "," + value.upper_corner.text_representation + ")"
          "#{table_name}.#{column_name} && SetSRID(?::box3d, #{value.srid} ) "
        else
          "#{table_name}.#{column_name} && ? "
        end
      else
        attribute_condition("#{table_name}.#{column_name}", value)
      end
    end.join(' AND ')
  end

  #For Rails >= 2
  if method(:sanitize_sql_hash_for_conditions).arity == 1
    # Before Rails 2.3.3, the method had only one argument
    def self.sanitize_sql_hash_for_conditions(attrs)
      conditions = get_conditions(attrs)
      replace_bind_variables(conditions, expand_range_bind_variables(attrs.values))
    end
  elsif method(:sanitize_sql_hash_for_conditions).arity == -2
    # After Rails 2.3.3, the method had only two args, the last one optional
    def self.sanitize_sql_hash_for_conditions(attrs, table_name = quoted_table_name)
      attrs = expand_hash_conditions_for_aggregates(attrs)

      conditions = attrs.map do |attr, value|
        unless value.is_a?(Hash)
          attr = attr.to_s

          # Extract table name from qualified attribute names.
          if attr.include?('.')
            table_name, attr = attr.split('.', 2)
            table_name = connection.quote_table_name(table_name)
          end

          if columns_hash[attr].is_a?(SpatialColumn)
            if value.is_a?(Array)
              attrs[attr.to_sym]= "BOX3D(" + value[0].join(" ") + "," + value[1].join(" ") + ")"
              "#{table_name}.#{connection.quote_column_name(attr)} && SetSRID(?::box3d, #{value[2] || DEFAULT_SRID} ) "
            elsif value.is_a?(Envelope)
              attrs[attr.to_sym]= "BOX3D(" + value.lower_corner.text_representation + "," + value.upper_corner.text_representation + ")"
              "#{table_name}.#{connection.quote_column_name(attr)} && SetSRID(?::box3d, #{value.srid} ) "
            else
              "#{table_name}.#{connection.quote_column_name(attr)} && ? "
            end
          else
            attribute_condition("#{table_name}.#{connection.quote_column_name(attr)}", value)
          end
        else
          sanitize_sql_hash_for_conditions(value, connection.quote_table_name(attr.to_s))
        end
      end.join(' AND ')

      replace_bind_variables(conditions, expand_range_bind_variables(attrs.values))
    end
  else
    raise "Spatial Adapter will not work with this version of Rails"
  end
end

ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.class_eval do

  include SpatialAdapter

  # SCHEMA STATEMENTS ========================================
  #
  # Use :template on database.yml seems a better practice.
  #
  # alias :original_recreate_database :recreate_database
  # def recreate_database(configuration, enc_option)
  #   `dropdb -U "#{configuration["test"]["username"]}" #{configuration["test"]["database"]}`
  #   `createdb #{enc_option} -U "#{configuration["test"]["username"]}" #{configuration["test"]["database"]}`
  #   `createlang -U "#{configuration["test"]["username"]}" plpgsql #{configuration["test"]["database"]}`
  #   `psql -d #{configuration["test"]["database"]} -f db/spatial/postgis.sql`
  #   `psql -d #{configuration["test"]["database"]} -f db/spatial/spatial_ref_sys.sql`
  # end

  # alias :original_create_database :create_database
  # def create_database(name, options = {})
  #   original_create_database(name, options = {})
  #   `createlang plpgsql #{name}`
  #   `psql -d #{name} -f db/spatial/postgis.sql`
  #   `psql -d #{name} -f db/spatial/spatial_ref_sys.sql`
  # end

  alias :original_native_database_types :native_database_types
  def native_database_types
    original_native_database_types.update(geometry_data_types)
  end

  # Hack to make it works with Rails 3.1
  alias :original_type_cast :type_cast rescue nil
  def type_cast(value, column)
    return value.as_hex_ewkb if value.is_a?(GeoRuby::SimpleFeatures::Geometry)
    original_type_cast(value,column)
  end

  alias :original_quote :quote
  #Redefines the quote method to add behaviour for when a Geometry is encountered
  def quote(value, column = nil)
    if value.kind_of?(GeoRuby::SimpleFeatures::Geometry)
      "'#{value.as_hex_ewkb}'"
    else
      original_quote(value,column)
    end
  end

  alias :original_tables :tables
  def tables(name = nil) #:nodoc:
    original_tables(name) + views(name)
  end

  def views(name = nil) #:nodoc:
    schemas = schema_search_path.split(/,/).map { |p| quote(p.strip) }.join(',')
    query(<<-SQL, name).map { |row| row[0] }
      SELECT viewname
      FROM pg_views
      WHERE schemaname IN (#{schemas})
    SQL
  end

  def create_table(name, options = {})
    table_definition = ActiveRecord::ConnectionAdapters::PostgreSQLTableDefinition.new(self)
    table_definition.primary_key(options[:primary_key] || "id") unless options[:id] == false

    yield table_definition

    if options[:force]
      drop_table(name) rescue nil
    end

    create_sql = "CREATE#{' TEMPORARY' if options[:temporary]} TABLE "
    create_sql << "#{name} ("
    create_sql << table_definition.to_sql
    create_sql << ") #{options[:options]}"
    execute create_sql

    #added to create the geometric columns identified during the table definition
    unless table_definition.geom_columns.nil?
      table_definition.geom_columns.each do |geom_column|
        execute geom_column.to_sql(name)
      end
    end
  end

  alias :original_remove_column :remove_column
  def remove_column(table_name,column_name, options = {})
    columns(table_name).each do |col|
      if col.name == column_name.to_s
        #check if the column is geometric
        unless geometry_data_types[col.type].nil? or
               (options[:remove_using_dropgeometrycolumn] == false)
          execute "SELECT DropGeometryColumn('#{table_name}','#{column_name}')"
        else
          original_remove_column(table_name,column_name)
        end
      end
    end
  end

  alias :original_add_column :add_column
  def add_column(table_name, column_name, type, options = {})
    unless geometry_data_types[type].nil? or (options[:create_using_addgeometrycolumn] == false)
      geom_column = ActiveRecord::ConnectionAdapters::PostgreSQLColumnDefinition.
        new(self,column_name, type, nil,nil,options[:null],options[:srid] || -1 ,
        options[:with_z] || false , options[:with_m] || false)

      execute geom_column.to_sql(table_name)
    else
      original_add_column(table_name,column_name,type,options)
    end
  end

  # Adds a GIST spatial index to a column. Its name will be
  # <table_name>_<column_name>_spatial_index unless
  # the key :name is present in the options hash, in which case its
  # value is taken as the name of the index.
  def add_index(table_name, column_name, options = {})
    index_name = options[:name] || index_name(table_name,:column => Array(column_name))
    if options[:spatial]
      execute "CREATE INDEX #{index_name} ON #{table_name} USING GIST (#{Array(column_name).join(", ")} GIST_GEOMETRY_OPS)"
    else
      super
    end
  end

  def indexes(table_name, name = nil) #:nodoc:
    result = query(<<-SQL, name)
          SELECT i.relname, d.indisunique, a.attname , am.amname
            FROM pg_class t, pg_class i, pg_index d, pg_attribute a, pg_am am
           WHERE i.relkind = 'i'
             AND d.indexrelid = i.oid
             AND d.indisprimary = 'f'
             AND t.oid = d.indrelid
             AND i.relam = am.oid
             AND t.relname = '#{table_name}'
             AND a.attrelid = t.oid
             AND ( d.indkey[0]=a.attnum OR d.indkey[1]=a.attnum
                OR d.indkey[2]=a.attnum OR d.indkey[3]=a.attnum
                OR d.indkey[4]=a.attnum OR d.indkey[5]=a.attnum
                OR d.indkey[6]=a.attnum OR d.indkey[7]=a.attnum
                OR d.indkey[8]=a.attnum OR d.indkey[9]=a.attnum )
          ORDER BY i.relname
        SQL

    current_index = nil
    indexes = []

    result.each do |row|
      if current_index != row[0]
        #index type gist indicates a spatial index (probably not totally true but let's simplify!)
        indexes << ActiveRecord::ConnectionAdapters::IndexDefinition.
          new(table_name, row[0], row[1] == "t", row[3] == "gist" ,[])

        current_index = row[0]
      end
      indexes.last.columns << row[2]
    end
    indexes
  end

  def columns(table_name, name = nil) #:nodoc:
    raw_geom_infos = column_spatial_info(table_name)

    column_definitions(table_name).collect do |name, type, default, notnull|
      if type =~ /geometry/i
        raw_geom_info = raw_geom_infos[name]
        if raw_geom_info.nil?
          ActiveRecord::ConnectionAdapters::SpatialPostgreSQLColumn.create_simplified(name, default, notnull == "f")
        else
          ActiveRecord::ConnectionAdapters::SpatialPostgreSQLColumn.new(name, default,raw_geom_info.type, notnull == "f", raw_geom_info.srid, raw_geom_info.with_z, raw_geom_info.with_m)
        end
      else
        ActiveRecord::ConnectionAdapters::PostgreSQLColumn.new(name, default, type, notnull == "f")
      end
    end
  end

 # For version of Rails where exists disable_referential_integrity
 if self.instance_methods.include? :disable_referential_integrity
   #Pete Deffendol's patch
   alias :original_disable_referential_integrity :disable_referential_integrity
   def disable_referential_integrity(&block) #:nodoc:
     execute(tables.reject { |name| PostgisAdapter::IGNORE_TABLES.include?(name) }.map { |name| "ALTER TABLE #{quote_table_name(name)} DISABLE TRIGGER ALL" }.join(";"))
     yield
   ensure
     execute(tables.reject { |name| PostgisAdapter::IGNORE_TABLES.include?(name) }.map { |name| "ALTER TABLE #{quote_table_name(name)} ENABLE TRIGGER ALL" }.join(";"))
   end
 end

  private

  def column_spatial_info(table_name)
    constr = query <<-end_sql
SELECT * FROM geometry_columns WHERE f_table_name = '#{table_name}'
    end_sql

    raw_geom_infos = {}
    constr.each do |constr_def_a|
      raw_geom_infos[constr_def_a[3]] ||= ActiveRecord::ConnectionAdapters::RawGeomInfo.new
      raw_geom_infos[constr_def_a[3]].type = constr_def_a[6]
      raw_geom_infos[constr_def_a[3]].dimension = constr_def_a[4].to_i
      raw_geom_infos[constr_def_a[3]].srid = constr_def_a[5].to_i

      if raw_geom_infos[constr_def_a[3]].type[-1] == ?M
        raw_geom_infos[constr_def_a[3]].with_m = true
        raw_geom_infos[constr_def_a[3]].type.chop!
      else
        raw_geom_infos[constr_def_a[3]].with_m = false
      end
    end

    raw_geom_infos.each_value do |raw_geom_info|
      #check the presence of z and m
      raw_geom_info.convert!
    end

    raw_geom_infos
  rescue => e
    nil
  end

end

module ActiveRecord
  module ConnectionAdapters
    class RawGeomInfo < Struct.new(:type,:srid,:dimension,:with_z,:with_m) #:nodoc:
      def convert!
        self.type = "geometry" if self.type.nil? #if geometry the geometrytype constraint is not present : need to set the type here then

        if dimension == 4
          self.with_m = true
          self.with_z = true
        elsif dimension == 3
          if with_m
            self.with_z = false
            self.with_m = true
          else
            self.with_z = true
            self.with_m = false
          end
        else
          self.with_z = false
          self.with_m = false
        end
      end
    end
  end
end


module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLTableDefinition < TableDefinition
      attr_reader :geom_columns

      def column(name, type, options = {})
        unless (@base.geometry_data_types[type.to_sym].nil? or
                (options[:create_using_addgeometrycolumn] == false))

          geom_column = PostgreSQLColumnDefinition.new(@base,name, type)
          geom_column.null = options[:null]
          geom_column.srid = options[:srid] || -1
          geom_column.with_z = options[:with_z] || false
          geom_column.with_m = options[:with_m] || false

          @geom_columns = [] if @geom_columns.nil?
          @geom_columns << geom_column
        else
          super(name,type,options)
        end
      end

      SpatialAdapter.geometry_data_types.keys.each do |column_type|
        class_eval <<-EOV
          def #{column_type}(*args)
            options = args.extract_options!
            column_names = args

            column_names.each { |name| column(name, '#{column_type}', options) }
          end
        EOV
      end
    end

    class PostgreSQLColumnDefinition < ColumnDefinition
      attr_accessor :srid, :with_z,:with_m
      attr_reader :spatial

      def initialize(base = nil, name = nil, type=nil, limit=nil, default=nil,null=nil,srid=-1,with_z=false,with_m=false)
        super(base, name, type, limit, default,null)
        @spatial=true
        @srid=srid
        @with_z=with_z
        @with_m=with_m
      end

      def to_sql(table_name)
        if @spatial
          type_sql = type_to_sql(type.to_sym)
          type_sql += "M" if with_m and !with_z
          if with_m and with_z
            dimension = 4
          elsif with_m or with_z
            dimension = 3
          else
            dimension = 2
          end

          column_sql = "SELECT AddGeometryColumn('#{table_name}','#{name}',#{srid},'#{type_sql}',#{dimension})"
          column_sql += ";ALTER TABLE #{table_name} ALTER #{name} SET NOT NULL" if null == false
          column_sql
        else
          super
        end
      end


      private
      def type_to_sql(name, limit=nil)
        base.type_to_sql(name, limit) rescue name
      end

    end

  end
end

# Would prefer creation of a PostgreSQLColumn type instead but I would
# need to reimplement methods where Column objects are instantiated so
# I leave it like this
module ActiveRecord
  module ConnectionAdapters
    class SpatialPostgreSQLColumn < Column

      include SpatialColumn

      #Transforms a string to a geometry. PostGIS returns a HexEWKB string.
      def self.string_to_geometry(string)
        return string unless string.is_a?(String)
        GeoRuby::SimpleFeatures::Geometry.from_hex_ewkb(string) rescue nil
      end

      def self.create_simplified(name,default,null = true)
        new(name,default,"geometry",null,nil,nil,nil)
      end

    end
  end
end
