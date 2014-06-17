$:.push File.expand_path("../lib", __FILE__)

# Provide a simple gemspec so you can easily use your enginex
# project in your rails apps through git.

require 'bulk_fetcher/version'

Gem::Specification.new do |s|
  s.name = "bulk_fetcher"
  s.version = BulkFetcher::VERSION
  s.description = 'Fetch things in bulk and store them for later'
  s.summary = 'Fetch things in bulk and store them for later'

  s.add_development_dependency "mocha"
  s.add_development_dependency "minitest", '>= 5'
  s.license = "MIT"

  s.author = "Jeff Ching"
  s.email = "ching.jeff@gmail.com"
  s.homepage = "http://github.com/chingor13/bulk_fetcher"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir.glob('test/*_test.rb')
end
