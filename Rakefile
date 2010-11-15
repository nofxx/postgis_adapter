require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/rdoctask'
require 'spec/rake/spectask'

CLEAN.include('**/*.gem')

namespace :gem do
  desc "Create the postgis_adapter gem"
  task :create => [:clean] do
    spec = eval(IO.read('postgis_adapter.gemspec'))
    Gem::Builder.new(spec).build
  end

  desc "Install the postgis_adapter gem"
  task :install => [:create] do
    file = Dir['*.gem'].first
    sh "gem install #{file}"
  end
end

Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION').chomp : ""
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "postgis_adapter #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :default => :spec

#
# Reek & Roodi
#
begin
  require 'reek/rake_task'
  Reek::RakeTask.new do |t|
    t.fail_on_error = true
    t.verbose = false
    t.source_files = 'lib/**/*.rb'
  end
rescue LoadError
  task :reek do
    abort "Reek is not available. In order to run reek, you must: sudo gem install reek"
  end
end

begin
  require 'roodi'
  require 'roodi_task'
  RoodiTask.new do |t|
    t.verbose = false
  end
rescue LoadError
  task :roodi do
    abort "Roodi is not available. In order to run roodi, you must: sudo gem install roodi"
  end
end
