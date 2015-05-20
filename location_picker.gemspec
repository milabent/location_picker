$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "location_picker/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "location_picker"
  s.version     = LocationPicker::VERSION
  s.authors     = ["Georg Limbach, Sebastian Gaul"]
  s.email       = [""]
  s.homepage    = "http://milabent.com"
  s.summary     = "Map-based picker for longitude and latitude"
  s.description = "Map-based picker for longitude and latitude"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.2.0"
  s.add_dependency "leaflet-rails", "~> 0.7.4"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "vcr"
  s.add_development_dependency "webmock"
end
