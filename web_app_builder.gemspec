# -*- encoding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/lib/web_app_builder/version')

Gem::Specification.new do |spec|
  spec.name          = "web_app_builder"
  spec.summary       = %q{Class that helps to keep database credentials for rails application in private place}
  spec.description   = %q{Class that helps to keep database credentials for rails application in private place}
  spec.email         = "alexander.shvets@gmail.com"
  spec.authors       = ["Alexander Shvets"]
  spec.homepage      = "http://github.com/shvets/web_app_builder"

  spec.files         = `git ls-files`.split($\)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.version       = WebAppBuilder::VERSION

  spec.add_runtime_dependency "bundler", [">= 0"]
  spec.add_runtime_dependency "meta_methods", [">= 0"]
  spec.add_runtime_dependency "file_utils", [">= 0"]
  spec.add_runtime_dependency "zip_dsl", [">= 0"]
  spec.add_runtime_dependency "jruby-jars", [">= 0"]
  spec.add_runtime_dependency "jruby-rack", [">= 0"]
  spec.add_runtime_dependency "jruby-openssl", [">= 0"]
  spec.add_runtime_dependency "bouncy-castle-java", [">= 0"]
  spec.add_development_dependency "gemspec_deps_gen", [">= 0"]
  spec.add_development_dependency "gemcutter", [">= 0"]
  
end

