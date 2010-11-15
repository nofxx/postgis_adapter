SPEC_DB = {
  :adapter => "postgresql",
  :database => "postgis_adapter",
  :username => "postgres",
  :password => ""
}

require 'rubygems'
require 'pg'
$:.unshift((File.join(File.dirname(__FILE__), '..', 'lib')))

def try_old_stuff(*stuff)
  stuff.each do |s|
    begin
      require s[0]
    rescue LoadError
      require s[1]
    end
  end
end
try_old_stuff ['spec', 'rspec'], ['active_record', 'activerecord']

gem 'nofxx-georuby'
require 'postgis_adapter'
require 'logger'
# GeoRuby::SimpleFeatures::DEFAULT_SRID = -1

# Monkey patch Schema.define logger
$logger = Logger.new(StringIO.new)
def $logger.write(d); self.info(d); end
# $stdout = $logger

ActiveRecord::Base.logger = $logger

begin
  ActiveRecord::Base.establish_connection(SPEC_DB)
  ActiveRecord::Migration.verbose = false
  PG_VERSION = ActiveRecord::Base.connection.select_value("SELECT version()").scan(/PostgreSQL ([\d\.]*)/)[0][0]

  puts "Running against PostgreSQL #{PG_VERSION}"

  require File.dirname(__FILE__) + '/db/schema_postgis.rb'
  require File.dirname(__FILE__) + '/db/models_postgis.rb'

rescue PGError
  puts "No db... creating"
  `createdb -U #{SPEC_DB[:username]} #{SPEC_DB[:database]} -T template_postgis`
  puts "Done. Please run spec again."
  exit
end



