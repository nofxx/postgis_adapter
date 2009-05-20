# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{postgis_adapter}
  s.version = "0.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Marcos Augusto"]
  s.date = %q{2009-05-20}
  s.description = %q{Execute PostGIS functions on Active Record}
  s.email = %q{x@nofxx.com}
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    ".gitignore",
     "History.txt",
     "MIT-LICENSE",
     "Manifest.txt",
     "README.rdoc",
     "Rakefile",
     "VERSION.yml",
     "init.rb",
     "install.rb",
     "lib/postgis_adapter.rb",
     "lib/postgis_adapter/acts_as_geom.rb",
     "lib/postgis_adapter/common_spatial_adapter.rb",
     "lib/postgis_functions.rb",
     "lib/postgis_functions/bbox.rb",
     "lib/postgis_functions/class.rb",
     "lib/postgis_functions/common.rb",
     "postgis_adapter.gemspec",
     "rails/init.rb",
     "script/console",
     "script/destroy",
     "script/generate",
     "spec/db/database_postgis.yml",
     "spec/db/models_postgis.rb",
     "spec/db/schema_postgis.rb",
     "spec/postgis_adapter/acts_as_geom_spec.rb",
     "spec/postgis_adapter/common_spatial_adapter_spec.rb",
     "spec/postgis_adapter_spec.rb",
     "spec/postgis_functions/bbox_spec.rb",
     "spec/postgis_functions/class_spec.rb",
     "spec/postgis_functions/common_spec.rb",
     "spec/postgis_functions_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb",
     "uninstall.rb"
  ]
  s.homepage = %q{http://github.com/nofxx/postgis_adapter}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{postgis_adapter}
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{PostGIS Adapter for Active Record}
  s.test_files = [
    "spec/postgis_functions_spec.rb",
     "spec/postgis_functions/class_spec.rb",
     "spec/postgis_functions/bbox_spec.rb",
     "spec/postgis_functions/common_spec.rb",
     "spec/db/models_postgis.rb",
     "spec/db/schema_postgis.rb",
     "spec/postgis_adapter_spec.rb",
     "spec/postgis_adapter/common_spatial_adapter_spec.rb",
     "spec/postgis_adapter/acts_as_geom_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<geo_ruby>, [">= 0"])
    else
      s.add_dependency(%q<geo_ruby>, [">= 0"])
    end
  else
    s.add_dependency(%q<geo_ruby>, [">= 0"])
  end
end
