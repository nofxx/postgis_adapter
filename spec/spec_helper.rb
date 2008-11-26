begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'spec'
end
require 'activerecord'
$:.unshift(File.dirname(__FILE__) + '/../lib')
ActiveRecord::Base.establish_connection(YAML.load_file(
  File.dirname(__FILE__) + '/db/database_postgis.yml'))
require File.dirname(__FILE__) + '/../init.rb'
require File.dirname(__FILE__) + '/db/models_postgis.rb'
