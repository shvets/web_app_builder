source "https://rubygems.org"

group :default do
  gem "bundler"
  gem "meta_methods"
  gem "file_utils"
  gem "zip_dsl"
  
  if RUBY_PLATFORM == 'java'
    gem "jruby-jars"
    gem "jruby-rack"
    gem "jruby-openssl"
    gem "bouncy-castle-java"
  end
end

group :development do
  gem "gemspec_deps_gen"
  gem "gemcutter"
end

group :test do
  gem "rspec"
  gem "mocha"
end