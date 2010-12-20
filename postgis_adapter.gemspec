Gem::Specification.new do |spec|
  spec.name     = 'postgis_adapter'
  spec.version  = '0.7.9'
  spec.authors  = ['Marcos Piccinini']
  spec.summary  = 'PostGIS Adapter for Active Record'
  spec.email    = 'x@nofxx.com'
  spec.homepage = 'http://github.com/nofxx/postgis_adapter'

  spec.rdoc_options = ['--charset=UTF-8']
  spec.rubyforge_project = 'postgis_adapter'

  spec.files = Dir['**/*'].reject{ |f| f.include?('git') }
  spec.test_files = Dir['spec/**/*.rb']
  spec.extra_rdoc_files  = ['README.rdoc']

  spec.add_dependency 'GeoRuby'

  spec.description = 'Execute PostGIS functions on Active Record'
end
