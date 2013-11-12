# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails_kvs_driver/redis_driver/version'

Gem::Specification.new do |spec|
  spec.name          = "rails_kvs_driver-redis_driver"
  spec.version       = RailsKvsDriver::RedisDriver::VERSION
  spec.authors       = ["alfa-jpn"]
  spec.email         = ["a.nkmr.ja@gmail.com"]
  spec.description   = "rails_kvs_driver is available to use namespace and connection pool and ruby-like methods of kvs."
  spec.summary       = "redis driver for rails kvs driver."
  spec.homepage      = "https://github.com/alfa-jpn/rails_kvs_driver-redis_driver"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "yard"

  spec.add_dependency "redis"
  spec.add_dependency "rails_kvs_driver", "0.1.6"
end
