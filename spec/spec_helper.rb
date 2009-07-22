require 'rubygems'
require 'spec'
require 'pg'
require 'activerecord'
# require 'rspec_spinner'

gem 'activerecord', "=2.3.3"

$:.unshift((File.join(File.dirname(__FILE__), '..', 'lib')))
require 'postgis_adapter'
GeoRuby::SimpleFeatures.srid = -1

ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.establish_connection({ :adapter => "postgresql", :database => "postgis_plugin",
                                          :username => "postgres", :password => "" })
require File.dirname(__FILE__) + '/db/schema_postgis.rb'
require File.dirname(__FILE__) + '/db/models_postgis.rb'
