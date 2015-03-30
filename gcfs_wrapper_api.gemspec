$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "gcfs_wrapper_api/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name          = "gcfs_wrapper_api"
  spec.version       = Gcfs::Wrapper::Api::VERSION
  spec.authors       = ["Derri Mahendra"]
  spec.email         = ["derri@giftcard.co.id"]
  spec.summary       = ["Gem to wrap GCFS API"]
  spec.description   = ["Gem to wrap GCFS API"]
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  spec.test_files = Dir["test/**/*"]

  spec.add_dependency "rails"

  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "faker"
  
  spec.add_dependency "httparty"
  spec.add_dependency "kaminari"
end
