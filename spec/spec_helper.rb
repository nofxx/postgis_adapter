begin
  require 'spec'
  require 'postgres'
require 'activerecord'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'spec'
  require 'postgres'
require 'activerecord'
end

$:.unshift(File.dirname(__FILE__) + '/../lib')
config = YAML.load_file(File.dirname(__FILE__) + '/db/database_postgis.yml')
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.establish_connection(config)

require File.dirname(__FILE__) + '/../init.rb'
require File.dirname(__FILE__) + '/db/models_postgis.rb'

def load_schema
  load(File.dirname(__FILE__) + "/db/schema_postgis.rb")
end

