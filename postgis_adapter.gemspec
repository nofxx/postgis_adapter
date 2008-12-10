# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{postgis_adapter}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Marcos Piccinini"]
  s.date = %q{2008-12-10}
  s.description = %q{Postgis Adapter for Activer Record}
  s.email = ["x@nofxx.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt"]
  s.files = ["History.txt", "MIT-LICENSE", "Manifest.txt", "README.markdown", "Rakefile", "init.rb", "install.rb", "lib/postgis_adapter.rb", "lib/postgis_adapter/acts_as_geom.rb", "lib/postgis_adapter/common_spatial_adapter.rb", "lib/postgis_functions.rb", "lib/postgis_functions/bbox.rb", "lib/postgis_functions/class.rb", "lib/postgis_functions/common.rb", "lib/postgis_functions/linestring.rb", "lib/postgis_functions/point.rb", "lib/postgis_functions/polygon.rb", "postgis_adapter.gemspec", "rails/init.rb", "script/console", "script/destroy", "script/generate", "spec/acts_as_geom_spec.rb", "spec/common_spatial_adapter_spec.rb", "spec/db/database_postgis.yml", "spec/db/models_postgis.rb", "spec/db/schema_postgis.rb", "spec/postgis_adapter_spec.rb", "spec/postgis_functions/bbox_spec.rb", "spec/postgis_functions/linestring_spec.rb", "spec/postgis_functions/point_spec.rb", "spec/postgis_functions/polygon_spec.rb", "spec/postgis_functions_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "uninstall.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/nofxx/postgis_adapter}
  s.rdoc_options = ["--main", "README.markdown"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{postgis_adapter}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Postgis Adapter for Activer Record}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activerecord>, [">= 2.0.2"])
      s.add_development_dependency(%q<newgem>, [">= 1.1.0"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.0"])
    else
      s.add_dependency(%q<activerecord>, [">= 2.0.2"])
      s.add_dependency(%q<newgem>, [">= 1.1.0"])
      s.add_dependency(%q<hoe>, [">= 1.8.0"])
    end
  else
    s.add_dependency(%q<activerecord>, [">= 2.0.2"])
    s.add_dependency(%q<newgem>, [">= 1.1.0"])
    s.add_dependency(%q<hoe>, [">= 1.8.0"])
  end
end
