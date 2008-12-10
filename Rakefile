#$:.unshift(File.join(File.dirname(__FILE__) ,'../../gems/georuby/lib/'))
$:.unshift(File.join(File.dirname(__FILE__), 'lib'))
require 'rake'
require 'spec/rake/spectask'
require 'rake/rdoctask'
require 'active_record'
require 'active_record/connection_adapters/postgresql_adapter' 
%w[rubygems rake rake/clean fileutils newgem rubigen].each { |f| require f }
require File.dirname(__FILE__) + '/lib/postgis_adapter'

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)PostgisAdapter::VERSION
$hoe = Hoe.new('postgis_adapter', PostgisAdapter::VERSION) do |p|
  p.developer('Marcos Piccinini', 'x@nofxx.com')
  p.summary = "Postgis Adapter for Activer Record"
  p.description = "Postgis Adapter for Activer Record"
  p.url = "http://github.com/nofxx/postgis_adapter"
  p.changes              = p.paragraphs_of("History.txt", 0..1).join("\n\n")
#  p.post_install_message = 'PostInstall.txt' # TODO remove if post-install message not required
  p.rubyforge_name       = "postgis_adapter" # TODO this is default value
  p.extra_deps         = [
     ['activerecord','>= 2.0.2'],
  ]
  p.extra_dev_deps = [
    ['newgem', ">= #{::Newgem::VERSION}"]
  ]
  
  p.clean_globs |= %w[**/.DS_Store tmp *.log]
  path = (p.rubyforge_name == p.name) ? p.rubyforge_name : "\#{p.rubyforge_name}/\#{p.name}"
  p.remote_rdoc_dir = File.join(path.gsub(/^#{p.rubyforge_name}\/?/,''), 'rdoc')
  p.rsync_args = '-av --delete --ignore-errors'
end

require 'newgem/tasks' # load /tasks/*.rake
Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
# task :default => [:spec, :features]

desc 'Default: run specs.'
task :default => :spec

desc "Run all specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/*_spec.rb']
  t.spec_opts = ['--options', 'spec/spec.opts']
  unless ENV['NO_RCOV']
    t.rcov = true
    t.rcov_dir = 'coverage'
    t.rcov_opts = ['--html', '--exclude', "\.autotest,schema.rb,init.rb,\.gitignore,spec\/spec_helper.rb,spec\/db/*,#{ENV['GEM_HOME']}"]
  end
end

desc "Look for TODO and FIXME tags in the code"
task :todo do
  egrep /(FIXME|TODO|TBD)/
end

namespace :db do
  task :migrate do
    load('spec/db/schema_postgis.rb')
  end
end

desc "Generate the documentation"
Rake::RDocTask::new do |rdoc|
  rdoc.rdoc_dir = 'doc/'
  rdoc.title    = "PostGIS Adapter for Rails Documentation"
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

# From Rspec Rakefile
#
def egrep(pattern)
  Dir['**/*.rb'].each do |fn|
    count = 0
    open(fn) do |f|
      while line = f.gets
        count += 1
        if line =~ pattern
          puts "#{fn}:#{count}:#{line}"
        end
      end
    end
  end
end

desc "verify_committed, verify_rcov, post_news, release"
task :complete_release => [:verify_committed, :post_news, :release]

desc "Verifies that there is no uncommitted code"
task :verify_committed do
  IO.popen('git status') do |io|
    io.each_line do |line|
      raise "\n!!! Do a git commit first !!!\n\n" if line =~ /^#\s*modified:/
    end
  end
end
