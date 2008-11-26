$:.unshift(File.join(File.dirname(__FILE__) ,'../../gems/georuby/lib/'))
require 'rake'
require 'spec/rake/spectask'
require 'rake/rdoctask'


#namespace :test do
#  Rake::TestTask::new(:postgis => "db:postgis" ) do |t|
#    t.test_files = FileList['test/*_postgis_test.rb']
#    t.verbose = true
#  end
#end

namespace :db do
  task :migrate do
    load('spec/db/schema_postgis.rb')
  end
end

desc "Generate the documentation"
Rake::RDocTask::new do |rdoc|
  rdoc.rdoc_dir = 'doc/'
  rdoc.title    = "PostGIS Adapater for Rails Documentation"
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.markdown')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
