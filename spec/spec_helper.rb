require 'rubygems'
require 'spec'
require 'postgres'
require 'activerecord'
require 'rspec_spinner'

gem 'activerecord', "=2.3.2"

$:.unshift((File.join(File.dirname(__FILE__), '..', 'lib')))
require 'postgis_adapter'
GeoRuby::Base.srid = -1
config = YAML.load_file(File.dirname(__FILE__) + '/db/database_postgis.yml')
# ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.establish_connection(config)
#require File.dirname(__FILE__) + '/db/schema_postgis.rb'
require File.dirname(__FILE__) + '/db/models_postgis.rb'
