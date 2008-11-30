#$:.unshift(File.join(File.dirname(__FILE__) ,'../../gems/georuby/lib/'))
$:.unshift(File.join(File.dirname(__FILE__), 'lib'))
require 'rake'
require 'spec/rake/spectask'
require 'rake/rdoctask'


desc 'Default: run specs.'
task :default => :spec

#desc 'Run the specs'
#Spec::Rake::SpecTask.new(:spec) do |t|
#  t.spec_opts = ['--colour --format progress --loadby mtime --reverse']
#  t.spec_files = FileList['spec/**/*_spec.rb']
#end

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
  rdoc.rdoc_dir = 'rdoc/'
  rdoc.title    = "PostGIS Adapter for Rails Documentation"
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.markdown')
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
