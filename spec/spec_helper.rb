require 'rubygems'
require 'spec'
require 'pg'
require 'activerecord'
$:.unshift((File.join(File.dirname(__FILE__), '..', 'lib')))
gem 'activerecord', "=2.3.4"
gem 'nofxx-georuby'
require 'postgis_adapter'

# Monkey patch Schema.define logger
$logger = Logger.new(StringIO.new)
def $logger.write(d); self.info(d); end
# $stdout = $logger

GeoRuby::SimpleFeatures.srid = -1

ActiveRecord::Base.logger = $logger
ActiveRecord::Base.establish_connection({ :adapter => "postgresql", :database => "postgis_adapter",
                                          :username => "postgres", :password => "" })

PG_VERSION = ActiveRecord::Base.connection.select_value("SELECT version()").scan(/PostgreSQL ([\d\.]*)/)[0][0]

puts "Running against PostgreSQL #{PG_VERSION}"

require File.dirname(__FILE__) + '/db/schema_postgis.rb'
require File.dirname(__FILE__) + '/db/models_postgis.rb'
